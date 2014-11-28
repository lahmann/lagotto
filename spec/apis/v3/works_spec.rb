require "rails_helper"

describe "/api/v3/articles", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 55) }

    context "more than 50 works in query" do
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{work_list}&type=doi" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |work|
          work["doi"] == works[0].doi
          work["publication_date"] == works[0].published_on.to_time.utc.iso8601
        end).to be true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response.length).to eql(50)
        expect(response.any? do |work|
          work["doi"] == works[0].doi
          work["publication_date"] == works[0].published_on.to_time.utc.iso8601
        end).to be true
      end
    end
  end

  context "show" do

    context "show summary information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{work.doi_escaped}&type=doi&info=summary" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response["sources"]).to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response["sources"]).to be_nil
      end
    end

    context "show detail information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{work.doi_escaped}&info=detail" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.traces.first.event_count)
        expect(response_source["metrics"]["shares"]).to eq(work.traces.first.event_count)
        expect(response_source["events"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.traces.first.event_count)
        expect(response_source["metrics"]["shares"]).to eq(work.traces.first.event_count)
        expect(response_source["events"]).not_to be_nil
      end
    end

    context "show event information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{work.doi_escaped}&info=event" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.traces.first.event_count)
        expect(response_source["metrics"]["shares"]).to eq(work.traces.first.event_count)
        expect(response_source["events"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.traces.first.event_count)
        expect(response_source["metrics"]["shares"]).to eq(work.traces.first.event_count)
        expect(response_source["events"]).not_to be_nil
      end
    end
  end
end
