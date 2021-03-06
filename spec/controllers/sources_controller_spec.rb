require "rails_helper"

describe SourcesController, :type => :controller do
  render_views

  context "show" do
    it "redirects to the home page for an unknown source" do
      get source_path("x")
      expect(last_response.status).to eq(302)
      expect(last_response.body).to include("redirected")
    end
  end

  context "RSS" do

    before(:each) do
      FactoryGirl.create_list(:work_for_feed, 2)
    end

    let(:source) { FactoryGirl.create(:source) }

    it "returns an RSS feed for most-cited (7 days)" do
      get source_path(source, format: "rss", days: 7)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.display_name}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited (30 days)" do
      get source_path(source, format: "rss", days: 30)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.display_name}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited (12 months)" do
      get source_path(source, format: "rss", months: 12)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.display_name}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited" do
      get source_path(source, format: "rss")
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.display_name}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns a proper RSS error for an unknown source" do
      get source_path("x"), format: "rss"
      expect(last_response.status).to eq(404)
      response = Hash.from_xml(last_response.body)
      response = response["rss"]["channel"]
      expect(response["title"]).to eq("Lagotto: source not found")
      expect(response["link"]).to eq("http://example.org/")
    end
  end
end
