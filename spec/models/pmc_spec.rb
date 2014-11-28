require 'rails_helper'

describe Pmc, :type => :model do

  subject { FactoryGirl.create(:pmc) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  context "save PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }

    it "should fetch and save PMC data" do
      config = subject.publisher_configs.first
      publisher_id = config[0]
      journal = config[1].journals.split(" ").first
      stub = stub_request(:get, subject.get_feed_url(publisher_id, month, year, journal)).to_return(:body => File.read(fixture_path + 'pmc_alt.xml'))
      expect(subject.get_feed(month, year)).to be_empty
      file = "#{Rails.root}/data/pmcstat_#{journal}_#{month}_#{year}.xml"
      expect(File.exist?(file)).to be true
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(0)
    end
  end

  context "parse PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }

    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should parse PMC data" do
      config = subject.publisher_configs.first
      publisher_id = config[0]
      journal = config[1].journals.split(" ").first
      stub = stub_request(:get, subject.get_feed_url(publisher_id, month, year, journal)).to_return(:body => File.read(fixture_path + 'pmc_alt.xml'))
      expect(subject.get_feed(month, year)).to be_empty
      expect(subject.parse_feed(month, year)).to be_empty
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(0)
    end
  end

  context "get_data" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://127.0.0.1:5984/pmc_usage_stats_test/#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "pmc", :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>"http://www.ncbi.nlm.nih.gov/pmc/works/PMC2568856", :event_count=>0, :event_metrics=>{:pdf=>0, :html=>0, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(doi: work.doi, source: "pmc", events: [{ "unique-ip" => "0", "full-text" => "0", "pdf" => "0", "abstract" => "0", "scanned-summary" => "0", "scanned-page-browse" => "0", "figure" => "0", "supp-data" => "0", "cited-by" => "0", "year" => "2013", "month" => "10" }], :events_by_day=>[], events_by_month: [{ month: 10, year: 2013, html: 0, pdf: 0 }], :events_url=>"http://www.ncbi.nlm.nih.gov/pmc/works/PMC2568856", event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(2)
      expect(response[:event_count]).to eq(13)
      expect(response[:event_metrics]).to eq(pdf: 4, html: 9, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 13)
    end

    it "should catch timeout errors with the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://127.0.0.1:5984/pmc_usage_stats_test/", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
