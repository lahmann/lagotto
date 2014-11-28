require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:error) { { "error" => "Work not found."} }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 50) }

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=doi&info=summary"
      end

      it "no format" do
        get @uri
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["works"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["doi"] == works[0].doi
          expect(item["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["works"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["doi"] == works[0].doi
          expect(item["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "works found via PMID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmid}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=pmid&info=summary"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["works"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["pmid"] == works[0].pmid
        end).to be true
      end
    end

    context "works found via PMCID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmcid}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=pmcid&info=summary"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["works"]
        puts items[0]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["pmcid"] == works[0].pmcid
        end).to be true
      end
    end

    context "works found via Mendeley" do
      before(:each) do
        work_list = works.map { |work| "#{work.mendeley_uuid}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=mendeley_uuid&info=summary"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["works"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["mendeley_uuid"] == works[0].mendeley_uuid
        end).to be true
      end
    end

    context "no identifiers" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v6/works?info=summary"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        items = response["works"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["doi"] == works[0].doi
          expect(item["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v6/works?ids=xxx&info=summary" }
      let(:nothing_found) { { "meta" => { "total" => 0, "total_pages" => 0, "page" => 0 }, "works" => [] } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
