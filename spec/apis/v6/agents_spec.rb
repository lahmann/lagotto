require "rails_helper"

describe "/api/v6/agents", :type => :api do
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:headers) { { "HTTP_ACCEPT" => "application/json",
                    "Authorization" => "Token token=#{user.api_key}" } }
  let(:jsonp_headers) { { "HTTP_ACCEPT" => "application/javascript",
                          "Authorization" => "Token token=#{user.api_key}" } }

  context "index" do
    let(:uri) { "/api/v6/agents" }

    context "get jobs" do
      let!(:agent) { FactoryGirl.create(:agent_with_tasks) }
      let!(:delayed_job) { FactoryGirl.create(:delayed_job) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        response = response["agents"]
        item = response.first
        expect(item["name"]).to eq(agent.name)
        expect(item["status"]["stale"]).to eq(10)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response = response["agents"]
        item = response.first
        expect(item["name"]).to eq(agent.name)
        expect(item["status"]["stale"]).to eq(10)
      end
    end

    context "get responses" do
      let!(:agent) { FactoryGirl.create(:agent_with_api_responses) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        response = response["agents"]
        item = response.first
        expect(item["name"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response = response["agents"]
        item = response.first
        expect(item["name"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end
    end
  end

  context "show" do
    let(:uri) { "/api/v6/agents/#{agent.name}" }

    context "get jobs" do
      let!(:agent) { FactoryGirl.create(:agent_with_tasks) }
      let!(:delayed_job) { FactoryGirl.create(:delayed_job) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        item = response["agent"]
        expect(item["name"]).to eq(agent.name)
        expect(item["status"]["stale"]).to eq(10)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        item = response["agent"]
        expect(item["name"]).to eq(agent.name)
        expect(item["status"]["stale"]).to eq(10)
      end
    end
    context "get responses" do
      let(:agent) { FactoryGirl.create(:agent_with_api_responses) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        item = response["agent"]
        expect(item["name"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        item = response["agent"]
        expect(item["name"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end
    end
  end
end
