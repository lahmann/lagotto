require 'rails_helper'

describe Counter, :type => :model do
  subject { FactoryGirl.create(:counter) }
  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item'].length).to eq(37)
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { doi: work.doi, source: "counter", events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(doi: nil, source: "counter", events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "counter", events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(37)
      expect(response[:events_by_month].length).to eq(37)
      expect(response[:events_by_month].first).to eq(month: 1, year: 2010, html: 299, pdf: 90)
      expect(response[:events_url]).to be_nil
      expect(response[:event_count]).to eq(3387)
      expect(response[:event_metrics]).to eq(pdf: 447, html: 2919, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 3387)
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
