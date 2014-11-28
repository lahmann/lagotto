require "rails_helper"

describe "/api/v6/docs", :type => :api do
  context "index" do
    context "home page" do
      let(:uri) { "/api/v6/docs" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        doc = response["doc"]
        expect(doc["title"]).to eq("Home")
        expect(doc["layout"]).to eq("home")
        expect(doc["content"].length).to eq(5)
        subitem = doc["content"].first
        expect(subitem["subtitle"]).to include("Article-Level Metrics")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        doc = response["doc"]
        expect(doc["title"]).to eq("Home")
        expect(doc["layout"]).to eq("home")
        expect(doc["content"].length).to eq(5)
        subitem = doc["content"].first
        expect(subitem["subtitle"]).to include("Article-Level Metrics")
      end
    end
  end

  context "show" do
    context "card" do
      let(:uri) { "/api/v6/docs/contributors" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        doc = response["doc"]
        expect(doc["title"]).to eq("Contributors")
        expect(doc["layout"]).to eq("card")
        expect(doc["content"]).to include("The following people contributed")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        doc = response["doc"]
        expect(doc["title"]).to eq("Contributors")
        expect(doc["layout"]).to eq("card")
        expect(doc["content"]).to include("The following people contributed")
      end
    end

    context "card_list" do
      let(:uri) { "/api/v6/docs/roadmap" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        doc = response["doc"]
        expect(doc["title"]).to eq("Roadmap")
        expect(doc["layout"]).to eq("card_list")
        expect(doc["content"].length).to eq(4)
        subitem = doc["content"].first
        expect(subitem["subtitle"]).to include("Data-Push Model")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        doc = response["doc"]
        expect(doc["title"]).to eq("Roadmap")
        expect(doc["layout"]).to eq("card_list")
        expect(doc["content"].length).to eq(4)
        subitem = doc["content"].first
        expect(subitem["subtitle"]).to include("Data-Push Model")
      end
    end

    context "alert" do
      let(:uri) { "/api/v6/docs/connotea" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        doc = response["doc"]
        expect(doc["title"]).to eq("Connotea")
        expect(doc["layout"]).to eq("alert")
        expect(doc["content"]).to include("The Connotea source has been retired")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        doc = response["doc"]
        expect(doc["title"]).to eq("Connotea")
        expect(doc["layout"]).to eq("alert")
        expect(doc["content"]).to include("The Connotea source has been retired")
      end
    end
  end
end
