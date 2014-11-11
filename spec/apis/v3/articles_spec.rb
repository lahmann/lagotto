require "spec_helper"

describe "/api/v3/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "index" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 55) }

    context "more than 50 articles in query" do
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{article_list}&type=doi" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        Alert.count.should == 1
        alert = Alert.first
        alert.message.should eq("ActionController::UnpermittedParameters")
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    end
  end

  context "show" do

    context "show summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{article.doi_escaped}&type=doi&info=summary" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response["sources"].should be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response["sources"].should be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response["sources"].should be_nil
      end
    end

    context "show detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{article.doi_escaped}&info=detail" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["events"].should_not be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["events"].should_not be_nil
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
      end

    end

    context "show event information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles?api_key=#{api_key}&ids=#{article.doi_escaped}&info=event" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["events"].should_not be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.traces.first.event_count)
        response_source["metrics"]["shares"].should eq(article.traces.first.event_count)
        response_source["events"].should_not be_nil
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
      end
    end
  end
end
