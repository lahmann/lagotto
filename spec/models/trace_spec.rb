require 'spec_helper'

describe Trace do
  before(:each) { Date.stub(:today).and_return(Date.new(2013, 9, 5)) }

  it { should belong_to(:article) }
  it { should belong_to(:source) }

  describe "use stale_at" do
    let(:trace) { FactoryGirl.create(:trace) }

    it "stale_at should be a datetime" do
      trace.stale_at.should be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      (trace.stale_at - Time.zone.now).should be > 0
    end

    it "stale_at should be after article publication date" do
      (trace.stale_at - trace.article.published_on.to_datetime).should be > 0
    end
  end

  describe "staleness intervals" do
    it "published a day ago" do
      date = Date.today - 1.day
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      trace = FactoryGirl.create(:trace, :article => article)
      duration = trace.source.staleness[0]
      (trace.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Date.today - 8.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      trace = FactoryGirl.create(:trace, :article => article)
      duration = trace.source.staleness[1]
      (trace.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Date.today - 32.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      trace = FactoryGirl.create(:trace, :article => article)
      duration = trace.source.staleness[2]
      (trace.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Date.today - 370.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      trace = FactoryGirl.create(:trace, :article => article)
      duration = trace.source.staleness[3]
      (trace.stale_at - Time.zone.now).should be_within(0.15 * duration).of(duration)
    end
  end

  describe "CouchDB" do
    let(:trace) { FactoryGirl.create(:trace) }
    let(:rs_id) { "#{trace.source.name}:#{trace.article.doi_escaped}" }
    let(:error) { { "error" => "not_found", "reason" => "deleted" } }

    before(:each) do
      subject.put_lagotto_database
    end

    after(:each) do
      subject.delete_lagotto_database
    end

    it "should perform and get data" do
      stub = stub_request(:get, trace.source.get_query_url(trace.article))
        .to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = trace.perform_get_data

      rs_result = trace.get_lagotto_data(rs_id)
      # rs_result.should include("source" => trace.source.name,
      #                          "doi" => trace.article.doi,
      #                          "doc_type" => "current",
      #                          "_id" =>  "#{trace.source.name}:#{trace.article.doi}")
      # rh_result = trace.get_lagotto_data(rh_id)
      # rh_result.should include("source" => trace.source.name,
      #                          "doi" => trace.article.doi,
      #                          "doc_type" => "history",
      #                          "_id" => "#{rh_id}")

      # trace.article.destroy
      # subject.get_lagotto_data(rs_id).should eq(error)
      # subject.get_lagotto_data(rh_id).should eq(error)
    end
  end

  describe "retrieval_histories" do
    let(:trace) { FactoryGirl.create(:trace, :with_crossref_histories) }

    it "should get past events by month" do
      trace.get_past_events_by_month.should eq([{:year=>2013, :month=>4, :total=>800}, {:year=>2013, :month=>5, :total=>820}, {:year=>2013, :month=>6, :total=>870}, {:year=>2013, :month=>7, :total=>910}, {:year=>2013, :month=>8, :total=>950}])
    end
  end
end
