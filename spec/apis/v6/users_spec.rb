require "rails_helper"

describe "/api/v6/users", :type => :api do
  let(:headers) { { "HTTP_ACCEPT" => "application/json",
                  "Authorization" => "Token token=#{api_user.api_key}" } }
  let(:jsonp_headers) { { "HTTP_ACCEPT" => "application/javascript",
                          "Authorization" => "Token token=#{api_user.api_key}" } }

  context "index" do
    let(:uri) { "/api/v6/users" }

    context "as admin user" do
      let(:api_user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        users = response["users"]
        user = users.first
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        users = response["users"]
        user = users.first
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end

    context "as staff user" do
      let(:api_user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        users = response["users"]
        user = users.first
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        users = response["users"]
        user = users.first
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end

    context "as regular user" do
      let(:api_user) { FactoryGirl.create(:user, :role => "user") }
      let(:error) { {"error"=>"You are not authorized to access this page."} }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end
  end

  context "show" do
    let(:uri) { "/api/v6/users/#{api_user.id}" }

    context "as admin user" do
      let(:api_user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end

    context "as staff user" do
      let(:api_user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end

    context "as regular user" do
      let(:api_user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end

    context "different user page" do
      let(:api_user) { FactoryGirl.create(:admin_user) }
      let(:other_user) { FactoryGirl.create(:user, :role => "user") }
      let(:uri) { "/api/v6/users/#{other_user.id}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        user = response["user"]
        expect(user["name"]).to eq(api_user.name)
        expect(user["role"]).to eq(api_user.role)
      end
    end
  end
end
