require "spec_helper"

describe "/api/v5/agents" do
  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/agents?api_key=#{user.authentication_token}" }

    context "get jobs" do
      before(:each) do
        @agent = FactoryGirl.create(:agent)
        @delayed_job = FactoryGirl.create(:delayed_job)
        @articles = FactoryGirl.create_list(:article_with_events, 10)
        @agent.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["status"]["stale"].should == 10
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["status"]["stale"].should == 10
      end
    end

    context "get responses" do
      before(:each) do
        @agent = FactoryGirl.create(:agent_with_api_responses)
        @agent.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["responses"]["count"].should == 5
        item["responses"]["average"].should == 200
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["responses"]["count"].should == 5
        item["responses"]["average"].should == 200
      end
    end

    context "get events" do
      before(:each) do
        @agent = FactoryGirl.create(:agent)
        @articles = FactoryGirl.create_list(:article_with_events, 10)
        @agent.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["article_count"].should == 10
        item["event_count"].should == 500
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        item["name"].should eq(@agent.name)
        item["article_count"].should == 10
        item["event_count"].should == 500
      end
    end
  end

  context "show" do
    context "get response" do
      before(:each) do
        @agent = FactoryGirl.create(:agent_with_api_responses)
        @delayed_job = FactoryGirl.create(:delayed_job)
        @articles = FactoryGirl.create_list(:article_with_events, 5)
        @agent.update_cache
      end

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v5/agents/#{@agent.name}?api_key=#{user.authentication_token}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data["name"].should eq(@agent.name)
        data["article_count"].should == 5
        data["event_count"].should == 250
        data["responses"]["count"].should == 5
        data["responses"]["average"].should == 200
        data["status"]["stale"].should == 5
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        data["name"].should eq(@agent.name)
        data["article_count"].should == 5
        data["event_count"].should == 250
        data["responses"]["count"].should == 5
        data["responses"]["average"].should == 200
        data["status"]["stale"].should == 5
      end
    end
  end
end
