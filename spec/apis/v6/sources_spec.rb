require "rails_helper"

describe "/api/v6/sources", :type => :api do
  context "index" do
    let(:uri) { "/api/v6/sources" }

    context "get events" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 10)
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        sources = response["sources"]
        item = sources.first
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        sources = response["sources"]
        item = sources.first
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end
    end
  end

  context "show" do
    context "get response" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 5)
      end

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/sources/#{@source.name}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        item = response["source"]
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(5)
        expect(item["event_count"]).to eq(250)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        item = response["source"]
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(5)
        expect(item["event_count"]).to eq(250)
      end
    end
  end
end
