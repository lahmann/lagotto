require "rails_helper"

describe "/api/v5/publishers", :type => :api do
  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/publishers?api_key=#{user.authentication_token}" }

    context "index" do
      before(:each) do
        @publisher = FactoryGirl.create(:publisher)
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        expect(item["title"]).to eq(@publisher.title)
        expect(item["name"]).to eq(@publisher.name)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
        expect(item["member_id"]).to eq(340)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil,
            "HTTP_ACCEPT" => "application/javascript"
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        expect(item["title"]).to eq(@publisher.title)
        expect(item["name"]).to eq(@publisher.name)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
        expect(item["member_id"]).to eq(340)
      end
    end
  end
end
