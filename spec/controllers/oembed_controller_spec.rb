require 'rails_helper'

describe Api::OembedController, :type => :controller do
  render_views

  let(:work) { FactoryGirl.create(:work_with_events) }
  let(:uri) { "/api/oembed?url=#{api_v6_work_url(work)}" }

  # context "discovery" do
  #   it "correct oembed link" do
  #     get "http://#{ENV['SERVERNAME']}/works/doi/#{work.doi}"
  #     expect(last_response.status).to eq(200)
  #     expect(last_response.body).to have_css(%Q(link[rel="alternate"][type="application/json+oembed"][title="Article oEmbed Profile"][href="#{uri}"]), visible: false)
  #     expect(Alert.count).to eq(0)
  #   end
  # end

  context "show" do
    it "GET oembed" do
      get uri
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed escaped" do
      get "http://#{ENV['SERVERNAME']}/api/oembed?url=maxwidth=474&maxheight=711&url=#{CGI.escape(api_v6_work_url(work))}&format=json"
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed JSON" do
      get "#{uri}&format=json"
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed XML" do
      get "#{uri}&format=xml"
      expect(last_response.status).to eq(200)
      response = Hash.from_xml(last_response.body)
      response = response["oembed"]
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end
  end

  context "errors" do
    it "Not found JSON" do
      get "/api/oembed?url=x"
      expect(last_response.status).to eql(404)
      response = JSON.parse(last_response.body)
      expect(response).to eq("error" => "No work found.")
    end

    it "Not found XML" do
      get "/api/oembed?url=x&format=xml"
      expect(last_response.status).to eql(404)
      response = Hash.from_xml(last_response.body)
      expect(response).to eq("error" => "No work found.")
    end
  end
end
