require 'rails_helper'

describe ArticleCoverage, :type => :model do
  subject { FactoryGirl.create(:article_coverage) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0047712", published_on: "2013-11-01") }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
    expect(subject.get_data(work)).to eq({})
  end

  context "get_data from the Article Coverage API" do
    it "should report if work doesn't exist in Article Coverage source" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => {"error" => "Article not found"}.to_json, :status => 404)
      expect(subject.get_data(work)).to eq(error: "Article not found", status: 404)
      expect(stub).to have_been_requested
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008775")
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if work doesn't exist in Article Coverage source" do
      result = { error: "{\"error\":\"Work not found\"}" }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(2)

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2013, month: 11, day: 20, total: 2)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2013, month: 11, total: 2)

      expect(response[:event_count]).to eq(2)
      event = response[:events].first
      event_data = event[:event]
      expect(event_data['referral']).to eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
      expect(event_data['language']).to eq("English")
      expect(event_data['title']).to eq("Everything You Know About Your Personal Hygiene Is Wrong")
      expect(event_data['type']).to eq("Blog")
      expect(event_data['publication']).to eq("The Huffington Post")
      expect(event_data['published_on']).to eq("2013-11-20T00:00:00Z")
      expect(event_data['link_state']).to eq("APPROVED")

      expect(event[:event_time]).to eq("2013-11-20T00:00:00Z")
      expect(event[:event_url]).to eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
