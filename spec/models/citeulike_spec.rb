require 'rails_helper'

describe Citeulike, :type => :model do
  subject { FactoryGirl.create(:citeulike) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", published_on: "2006-06-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq('data' => body)
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the CiteULike API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { doi: work.doi, source: "citeulike", events: [], :events_by_day=>[], :events_by_month=>[], events_url: subject.get_events_url(work), event_count: 0, event_metrics: { pdf: nil, html: nil, shares: 0, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "citeulike", events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: 0, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are no events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      result = Hash.from_xml(body)
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      result = { 'data' => body }
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      result = Hash.from_xml(body)

      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(25)
      expect(response[:events_by_month].length).to eq(21)
      expect(response[:events_by_month].first).to eq(year: 2006, month: 6, total: 2)
      expect(response[:events_url]).to eq(subject.get_events_url(work))
      expect(response[:event_count]).to eq(25)
      event = response[:events].first
      expect(event[:event_time]).to eq("2006-06-13T16:14:19Z")
      expect(event[:event_url]).to eq(event[:event]['link']['url'])
    end

    it "should report if there is one event returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_one.xml')
      result = Hash.from_xml(body)

      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2006, month: 6, total: 1)
      expect(response[:events_url]).to eq(subject.get_events_url(work))
      expect(response[:event_count]).to eq(1)
      event = response[:events].first
      expect(event[:event_time]).to eq("2006-06-13T16:14:19Z")
      expect(event[:event_url]).to eq(event[:event]['link']['url'])
    end

    it "should catch timeout errors with the CiteULike API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
