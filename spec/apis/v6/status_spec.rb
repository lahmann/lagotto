require "rails_helper"

describe "/api/v6/status", :type => :api do
  subject { Status.new }

  context "show" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v6/status" }

    context "get response" do
      before(:each) do
        date = Date.today - 1.day
        FactoryGirl.create_list(:work_with_events, 5, year: date.year, month: date.month, day: date.day)
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:delayed_job)
        FactoryGirl.create_list(:api_request, 4)
        FactoryGirl.create_list(:api_response, 6)
        body = File.read(fixture_path + 'releases.json')
        stub_request(:get, "https://api.github.com/repos/articlemetrics/lagotto/releases").to_return(body: body)
        subject.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => "application/json"
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        status = response["status"]
        expect(status["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(status["works_count"]).to eq(5)
        expect(status["responses_count"]).to eq(6)
        expect(status["users_count"]).to eq(1)
        expect(status["version"]).to eq(Rails.application.config.version)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        status = response["status"]
        expect(status["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(status["works_count"]).to eq(5)
        expect(status["responses_count"]).to eq(6)
        expect(status["users_count"]).to eq(1)
        expect(status["version"]).to eq(Rails.application.config.version)
      end
    end
  end
end
