require "rails_helper"

describe "/api/v5/articles", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Work not found."} }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 50) }

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?ids=#{work_list}&type=doi&info=summary&api_key=#{api_key}"
      end

      it "no format" do
        get @uri
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["data"]
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
        items = response["data"]
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
        @uri = "/api/v5/articles?ids=#{work_list}&type=pmid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["data"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["pmid"] == works[0].pmid
        end).to be true
      end
    end

    context "works found via PMCID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmcid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{work_list}&type=pmcid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        works = response["data"]
        expect(works.length).to eq(50)
        expect(works.any? do |work|
          work["pmcid"] == "2568856" # works[0].pmcid
        end).to be true
      end
    end

    context "works found via Mendeley" do
      before(:each) do
        work_list = works.map { |work| "#{work.mendeley_uuid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{work_list}&type=mendeley_uuid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        items = response["data"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["mendeley_uuid"] == works[0].mendeley_uuid
        end).to be true
      end
    end

    context "no identifiers" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        items = response["data"]
        expect(items.length).to eq(50)
        expect(items.any? do |item|
          item["doi"] == works[0].doi
          expect(item["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v5/articles?ids=xxx&info=summary&api_key=#{api_key}" }
      let(:nothing_found) { { "total" => 0, "total_pages" => 0, "page" => 0, "error" => nil, "data" => [] } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
