require "spec_helper"

describe "/api/v3/articles" do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eq(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"].should include("citations")
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["events"].should be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.traces.first.event_count)
        response_source["metrics"]["citations"].should be_nil
        response_source["metrics"]["shares"].to_i.should eq(article.traces.first.event_count)
        response_source["metrics"]["groups"].should be_nil
        response_source["metrics"]["html"].should be_nil
        response_source["metrics"]["likes"].should be_nil
        response_source["metrics"]["pdf"].should be_nil
        response_source["events"].should be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eq(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"].should include("citations")
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["events"].should be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.traces.first.event_count)
        response_source["metrics"]["citations"].should be_nil
        response_source["metrics"]["shares"].to_i.should eq(article.traces.first.event_count)
        response_source["metrics"]["groups"].should be_nil
        response_source["metrics"]["html"].should be_nil
        response_source["metrics"]["likes"].should be_nil
        response_source["metrics"]["pdf"].should be_nil
        response_source["events"].should be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }
      let(:error) { { "error"=>"Article not found." } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(404)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should eql(404)

        response = Hash.from_xml(last_response.body)["hash"]
        response.should eq (error)
      end
    end
  end
end
