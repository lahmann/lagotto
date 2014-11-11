require "spec_helper"

describe "/api/v5/articles" do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.traces.first.event_count)
        item_source["metrics"]["readers"].should eq(article.traces.first.event_count)
        item_source["metrics"].should include("comments")
        item_source["metrics"].should include("likes")
        item_source["metrics"].should include("html")
        item_source["metrics"].should include("pdf")
        item_source["metrics"].should_not include("citations")
        item_source["events"].should be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.traces.first.event_count)
        item_source["metrics"]["readers"].should eq(article.traces.first.event_count)
        item_source["metrics"].should include("comments")
        item_source["metrics"].should include("likes")
        item_source["metrics"].should include("html")
        item_source["metrics"].should include("pdf")
        item_source["metrics"].should_not include("citations")
        item_source["events"].should be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])
        item["sources"].should be_empty
      end
    end
  end
end
