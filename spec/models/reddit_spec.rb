require 'rails_helper'

describe Reddit, :type => :model do
  subject { FactoryGirl.create(:reddit) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Reddit API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Reddit API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Reddit API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.reddit.com/search.json?q=\"#{work.doi_escaped}\"&limit=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "reddit", :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>0, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Reddit API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(doi: work.doi, source: "reddit", events: [], event_count: 0, :events_by_day=>[], :events_by_month=>[], events_url: "http://www.reddit.com/search?q=\"#{work.doi_escaped}\"", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: 0, likes: 0, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the Reddit API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", published_on: "2013-05-03")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(3)
      expect(response[:event_count]).to eq(1171)
      expect(response[:event_metrics][:likes]).to eq(1013)
      expect(response[:event_metrics][:comments]).to eq(158)
      expect(response[:events_url]).to eq("http://www.reddit.com/search?q=\"#{work.doi_escaped}\"")

      expect(response[:events_by_day].length).to eq(2)
      expect(response[:events_by_day].first).to eq(year: 2013, month: 5, day: 7, total: 1)
      expect(response[:events_by_month].length).to eq(2)
      expect(response[:events_by_month].first).to eq(year: 2013, month: 5, total: 2)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Jjberg2", "given"=>""}])
      expect(event[:event_csl]['title']).to eq("AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!")
      expect(event[:event_csl]['container-title']).to eq("Reddit")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2013, 5, 15]])
      expect(event[:event_csl]['type']).to eq("personal_communication")

      expect(event[:event_time]).to eq("2013-05-15T17:06:24Z")
      expect(event[:event_url]).to eq(event[:event]['url'])
    end

    it "should catch timeout errors with the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.reddit.com/search.json?q=\"#{work.doi_escaped}\"", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
