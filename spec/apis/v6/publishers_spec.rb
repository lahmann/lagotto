require "rails_helper"

describe "/api/v6/publishers", :type => :api do
  context "index" do
    let(:uri) { "/api/v6/publishers" }

    context "index" do
      before(:each) do
        @publisher = FactoryGirl.create(:publisher)
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        publishers = response["publishers"]
        item = publishers.first
        expect(item["id"]).to eq(340)
        expect(item["name"]).to eq(@publisher.name)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil,
            "HTTP_ACCEPT" => "application/javascript"
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        publishers = response["publishers"]
        item = publishers.first
        expect(item["id"]).to eq(340)
        expect(item["name"]).to eq(@publisher.name)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
      end
    end
  end
end
