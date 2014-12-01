require 'rails_helper'

describe Work, :type => :model do

  let(:work) { FactoryGirl.create(:work) }

  subject { work }

  it { is_expected.to have_many(:traces).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:doi) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  context "validate doi format" do
    it "10.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.5555/12345678")
      expect(work).to be_valid
    end

    it "10.13039/100000001" do
      work = FactoryGirl.build(:work, :doi => "10.13039/100000001")
      expect(work).to be_valid
    end

    it "10.1386//crre.4.1.53_1" do
      work = FactoryGirl.build(:work, :doi => " 10.1386//crre.4.1.53_1")
      expect(work).to be_valid
    end

    it "10.555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.555/12345678")
      expect(work).not_to be_valid
    end

    it "8.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "8.5555/12345678")
      expect(work).not_to be_valid
    end

    it "10.asdf/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.asdf/12345678")
      expect(work).not_to be_valid
    end

    it "10.5555" do
      work = FactoryGirl.build(:work, :doi => "10.5555")
      expect(work).not_to be_valid
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, :doi => "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "validate date" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it 'validate date' do
      work = FactoryGirl.build(:work)
      expect(work).to be_valid
    end

    it 'validate date with missing day' do
      work = FactoryGirl.build(:work, day: nil)
      expect(work).to be_valid
    end

    it 'validate date with missing month and day' do
      work = FactoryGirl.build(:work, month: nil, day: nil)
      expect(work).to be_valid
    end

    it 'don\'t validate date with missing year, month and day' do
      work = FactoryGirl.build(:work, year: nil, month: nil, day: nil)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(year: ["is not a number"], published_on: ["is before 1650"])
    end

    it 'don\'t validate wrong date' do
      work = FactoryGirl.build(:work, month: 2, day: 30)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["is not a valid date"])
    end

    it 'don\'t validate date in the future' do
      date = Time.zone.now.to_date + 1.day
      work = FactoryGirl.build(:work, year: date.year, month: date.month, day: date.day)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["is a date in the future"])
    end

    it 'published_on' do
      work = FactoryGirl.create(:work)
      date = Date.new(work.year, work.month, work.day)
      expect(work.published_on).to eq(date)
    end

    it 'issued' do
      work = FactoryGirl.create(:work)
      expect(work.issued).to eq("date-parts" => [[work.year, work.month, work.day]])
    end

    it 'issued year month' do
      work = FactoryGirl.create(:work, year: 2013, month: 2, day: nil)
      expect(work.issued).to eq("date-parts"=>[[2013, 2]])
    end

    it 'issued year' do
      work = FactoryGirl.create(:work, year: 2013, month: nil, day: nil)
      expect(work.issued).to eq("date-parts"=>[[2013]])
    end
  end

  it 'sanitize title' do
    work = FactoryGirl.create(:work, title: "<italic>Test</italic>")
    expect(work.title).to eq("Test")
  end

  it 'to doi escaped' do
    expect(CGI.escape(work.doi)).to eq(work.doi_escaped)
  end

  it 'doi as url' do
    expect(Addressable::URI.encode("http://dx.doi.org/#{work.doi}")).to eq(work.doi_as_url)
  end

  it 'to_uri' do
    expect(Work.to_uri(work.doi)).to eq "doi/#{work.doi}"
  end

  it 'to_url' do
    expect(Work.to_url(work.doi)).to eq "http://dx.doi.org/#{work.doi}"
  end

  it 'to title escaped' do
    expect(CGI.escape(work.title.to_str).gsub("+", "%20")).to eq(work.title_escaped)
  end

  it "events count" do
    Work.all.each do |work|
      total = work.traces.reduce(0) { |sum, rs| sum + rs.event_count }
      expect(total).to eq(work.events_count)
    end
  end

  it "has events" do
    expect(Work.has_events.all? { |work| work.events_count > 0 }).to be true
  end

  it 'should get_url' do
    work = FactoryGirl.create(:work, canonical_url: nil)
    url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
    stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
    stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
    expect(work.get_url).not_to be_nil
    expect(work.canonical_url).to eq(url)
  end

  it 'should get_ids' do
    work = FactoryGirl.create(:work, pmid: nil)
    pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{work.doi_escaped}&idtype=doi&format=json"
    stub = stub_request(:get, pubmed_url).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'persistent_identifiers.json'), :status => 200)
    expect(work.get_ids).to be true
    expect(work.pmid).to eq("17183658")
    expect(stub).to have_been_requested
  end

  it "should get all_urls" do
    work = FactoryGirl.build(:work, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
    expect(work.all_urls).to eq([work.doi_as_url, work.canonical_url])
  end

  context "associations" do
    it "should create associated traces" do
      expect(Trace.count).to eq(0)
      @works = FactoryGirl.create_list(:work_with_events, 2)
      expect(Trace.count).to eq(2)
    end

    it "should delete associated traces" do
      @works = FactoryGirl.create_list(:work_with_events, 2)
      expect(Trace.count).to eq(2)
      @works.each(&:destroy)
      expect(Trace.count).to eq(0)
    end
  end
end
