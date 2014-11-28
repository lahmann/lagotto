require "rails_helper"

describe "/api/v6/deposits", :type => :api do
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:source) { FactoryGirl.create(:source) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "create" do
    let(:uri) { "/api/v6/deposits" }
    let(:data) { [{ "event_count" => 6 }] }
    let(:params) { { "deposit" => { "data" => data, "source_id" => source.name } } }

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to be_nil
        expect(response["deposit"]["source_id"]).to eq (source.name)
        expect(response["deposit"]["status"]).to eq ("waiting")
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(403)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("You are not authorized to access this page.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(403)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("You are not authorized to access this page.")
      end
    end

    context "with wrong API key" do
      let(:user) { FactoryGirl.create(:admin_user, authentication_token: 1) }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(403)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("You are not authorized to access this page.")
      end
    end

    context "with missing deposit param" do
      let(:params) { { "data" => data, "source_id" => source.name } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("param is missing or the value is empty: deposit")
      end
    end

    context "with missing source_id param" do
      let(:params) { { "deposit" => { "data" => data } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({"source_id"=>["can't be blank"]})
      end
    end

    context "with missing data param" do
      let(:params) { { "deposit" => { "source_id" => source.name } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({"data"=>["can't be blank"]})
      end
    end

    context "with unpermitted params" do
      let(:params) do
        { "deposit" => { "data" => data,
                         "source_id" => source.name,
                         "foo" => "bar" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("found unpermitted parameters: foo")

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("ActionController::UnpermittedParameters")
        expect(notification.status).to eq(422)
      end
    end
  end

  context "show" do
    let(:uri) { "/api/v6/deposits/#{deposit.uuid}" }

    context "waiting" do
      let(:deposit) { FactoryGirl.create(:deposit) }
      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to be_nil
        expect(response["deposit"]["source_id"]).to eq (source.name)
        expect(response["deposit"]["status"]).to eq ("waiting")
      end
    end
  end
end
