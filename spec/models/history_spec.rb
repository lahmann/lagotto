require 'rails_helper'

describe History, :type => :model do

  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2014, 7, 5))
  end

  let(:trace) { FactoryGirl.create(:trace) }

  context "error" do
    let(:data) { { doi: trace.work.doi, source: trace.source.name, error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{trace.work.doi_escaped}" } }
    let(:update_interval) { 30 }
    subject { History.new(data) }

    it "should have status error" do
      expect(subject.status).to eq(:error)
    end

    it "should respond to an error" do
      expect(subject.to_hash).to eq(event_count: nil, previous_count: 50, skipped: true, update_interval: update_interval)
    end
  end

  context "success no data" do
    let(:data) { { doi: trace.work.doi, source: trace.source.name, event_count: 0 } }
    let(:update_interval) { 30 }
    subject { History.new(data) }

    it "should have status success no data" do
      expect(subject.status).to eq(:success_no_data)
    end

    it "should respond to success with no data" do
      expect(subject.to_hash).to eq(event_count: 0, previous_count: 50, skipped: false, update_interval: update_interval)
    end
  end

  context "success" do
    before(:each) { subject.put_lagotto_database }
    after(:each) { subject.delete_lagotto_database }

    let(:data) { { doi: trace.work.doi, source: trace.source.name, event_count: 25, events_by_day: [], events_by_month: [] } }
    let(:update_interval) { 30 }
    subject { History.new(data) }

    it "should have status success" do
      expect(subject.status).to eq(:success)
    end

    it "should respond to success" do
      expect(subject.to_hash).to eq(event_count: 25, previous_count: 50, skipped: false, update_interval: update_interval)
    end
  end

  context "events_by_day" do
    before(:each) { subject.put_lagotto_database }
    after(:each) { subject.delete_lagotto_database }

    let(:data) { { doi: trace.work.doi, source: trace.source.name, event_count: 25, events_by_day: nil, event_metrics: { html: 15, pdf: 5, total: 25 } } }
    let(:today) { Time.zone.now.to_date }
    let(:yesterday) { Time.zone.now.to_date - 1.day }
    subject { History.new(data) }

    context "recent works from crossref" do
      let(:trace) { FactoryGirl.create(:trace, :with_crossref_and_work_published_today) }

      it "should generate events by day for recent works" do
        events_by_day = nil
        expect(subject.get_events_by_day(events_by_day)).to eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }])
      end

      it "should add to events by day for recent works" do
        events_by_day = [{ 'year' => yesterday.year, 'month' => yesterday.month, 'day' => yesterday.day, 'total' => 3 }]
        expect(subject.get_events_by_day(events_by_day)).to eq([events_by_day[0],
                                                            { 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by day for recent works" do
        events_by_day = [{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => 3 }]
        expect(subject.get_events_by_day(events_by_day)).to eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }])
      end
    end

    context "recent works from counter" do
      let(:trace) { FactoryGirl.create(:trace, :with_counter_and_work_published_today) }

      it "should generate events by day for recent works" do
        events_by_day = nil
        expect(subject.get_events_by_day(events_by_day)).to eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html], 'pdf' => data[:event_metrics][:pdf] }])
      end

      it "should add to events by day for recent works" do
        events_by_day = [{ 'year' => yesterday.year, 'month' => yesterday.month, 'day' => yesterday.day, 'html' => 12, 'pdf' => 4 }]
        expect(subject.get_events_by_day(events_by_day)).to eq([events_by_day[0],
                                                            { 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html] - 12, 'pdf' => data[:event_metrics][:pdf] - 4 }])
      end

      it "should update events by day for recent works" do
        events_by_day = [{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => 3 }]
        expect(subject.get_events_by_day(events_by_day)).to eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html], 'pdf' => data[:event_metrics][:pdf] }])
      end
    end

    context "old works" do
      it "should return events by day for old works" do
        events_by_day = [{ 'year' => today.year - 1, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }]
        expect(subject.get_events_by_day(events_by_day)).to eq(events_by_day)
      end

      it "should return events by day for old works, turning nil into an empty array" do
        expect(subject.get_events_by_day(data[:events_by_day])).to eq(Array(data[:events_by_day]))
      end
    end
  end

  context "events_by_month" do
    before(:each) { subject.put_lagotto_database }
    after(:each) { subject.delete_lagotto_database }

    let(:data) { { doi: trace.work.doi, source: trace.source.name, event_count: 25, events_by_month: nil, event_metrics: { html: 15, pdf: 5, total: 25 } } }
    let(:today) { Time.zone.now.to_date }
    let(:last_month) { Time.zone.now.to_date - 1.month }
    subject { History.new(data) }

    context "recent works from crossref" do
      let(:trace) { FactoryGirl.create(:trace, :with_crossref_and_work_published_today) }

      it "should generate events by month" do
        events_by_month = nil
        expect(subject.get_events_by_month(events_by_month)).to eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end

      it "should update events by month" do
        events_by_month = [{ 'year' => today.year, 'month' => today.month, 'total' => 3 }]
        expect(subject.get_events_by_month(events_by_month)).to eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end
    end

    context "older works from crossref" do
      let(:trace) { FactoryGirl.create(:trace, :with_crossref) }

      it "should generate events by month" do
        events_by_month = nil
        expect(subject.get_events_by_month(events_by_month)).to eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end

      it "should add to events by month" do
        events_by_month = [{ 'year' => last_month.year, 'month' => last_month.month, 'total' => 3 }]
        expect(subject.get_events_by_month(events_by_month)).to eq([events_by_month[0],
                                                                { 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by month" do
        events_by_month = [{ 'year' => last_month.year, 'month' => last_month.month, 'total' => 3 }, { 'year' => today.year, 'month' => today.month, 'total' => 10 }]
        expect(subject.get_events_by_month(events_by_month)).to eq([events_by_month[0],
                                                                { 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by month without previous month" do
        events_by_month = [{ 'year' => today.year, 'month' => today.month, 'total' => 0 }]
        expect(subject.get_events_by_month(events_by_month)).to eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end
    end
  end
end
