require 'rails_helper'

describe PmcEuropeData, :type => :model do
  subject { FactoryGirl.create(:pmc_europe_data) }

  let(:work) { FactoryGirl.build(:work, :pmid => "14624247") }

  context "get_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.build(:work, :pmid => "")
      pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{work.doi_escaped}&idtype=doi&format=json"
      stub = stub_request(:get, pubmed_url).to_return(:body => File.read(fixture_path + 'persistent_identifiers_nil.json'))
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe_data.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "get_data via accession_id" do
    it "should report that there are no events if the doi is missing" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      work = FactoryGirl.build(:work, :doi => "")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      work = FactoryGirl.build(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      body = File.read(fixture_path + 'pmc_europe_data.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:#{work.doi}", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.build(:work, :pmid => "")
      result = {}
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "pmc_europe_data", :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(doi: work.doi, source: "pmc_europe_data", events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: "http://europepmc.org/abstract/MED/#{work.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe_data.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(doi: work.doi, source: "pmc_europe_data", events: { "EMBL" => 10, "UNIPROT" => 21700 }, :events_by_day=>[], :events_by_month=>[], event_count: 21710, events_url: "http://europepmc.org/abstract/MED/#{work.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 21710, total: 21710 })
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end

  context "parse_data via accession_id" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => "", :pmid => "")
      result = {}
      expect(subject.parse_data(result, work)).to eq(doi: work.doi, source: "pmc_europe_data", :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "")
      body = File.read(fixture_path + 'pmc_europe_data_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(doi: work.doi, source: "pmc_europe_data", events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "")
      body = File.read(fixture_path + 'pmc_europe_data.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)
      expect(response[:events_url]).to be_nil

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Ha.", "given"=>"Piwowar"}])
      expect(event[:event_csl]['title']).to eq("Who shares? Who doesn't? Factors associated with openly archiving raw research data.")
      expect(event[:event_csl]['container-title']).to eq("PLoS One")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2011]])
      expect(event[:event_csl]['type']).to eq("work-journal")

      expect(event[:event_url]).to eq("http://europepmc.org/abstract/MED/21765886")
    end
  end
end
