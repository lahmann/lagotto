require "rails_helper"

describe "/api/v6/notifications", :type => :api do
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "most recent articles" do
      let(:uri) { "/api/v6/notifications" }

      before(:each) { FactoryGirl.create_list(:notification, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(50)
        notification = notifications.first
        expect(notification["level"]).to eq ("WARN")
        expect(notification["message"]).to eq ("The request timed out.")
      end
    end

    context "only unresolved notifications" do
      let(:uri) { "/api/v6/notifications?unresolved=1" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2, unresolved: false)
        FactoryGirl.create(:notification)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(1)
        notification = notifications.first
        expect(notification["unresolved"]).to be true
      end
    end

    context "with agent" do
      let(:uri) { "/api/v6/notifications?agent=citeulike" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification_with_agent)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(1)
        notification = notifications.first
        expect(notification["agent"]).to eq ("citeulike")
      end
    end

    context "with class_name" do
      let(:uri) { "/api/v6/notifications?class_name=nomethoderror" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(1)
        notification = notifications.first
        expect(notification["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with level ERROR" do
      let(:uri) { "/api/v6/notifications?level=error" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, level: Notification::ERROR)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(1)
        notification = notifications.first
        expect(notification["level"]).to eq ("ERROR")
      end
    end

    context "with query" do
      let(:uri) { "/api/v6/notifications?q=nomethod" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notifications"]
        expect(notifications.length).to eq(1)
        notification = notifications.first
        expect(notification["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with pagination" do
      let(:uri) { "/api/v6/notifications?page=2" }

      before(:each) { FactoryGirl.create_list(:notification, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        notifications = response["notification"]
        expect(notifications.length).to eq(5)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:uri) { "/api/v6/notifications" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq("error"=>"You are not authorized to access this page.")
      end
    end
  end
end
