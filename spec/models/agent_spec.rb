require 'rails_helper'

describe Agent, :type => :model do

  it { is_expected.to belong_to(:group) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }

  describe "get_events_by_day" do
    before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.ppat.1000446", published_on: "2013-08-05") }

    it "should handle events" do
      events = [{ event_time: (Date.today - 2.weeks).to_datetime.utc.iso8601 },
                { event_time: (Date.today - 2.weeks).to_datetime.utc.iso8601 },
                { event_time: (Date.today - 1.week).to_datetime.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work)).to eq([{:year=>2013, :month=>8, :day=>22, :total=>2}, {:year=>2013, :month=>8, :day=>29, :total=>1}])
    end

    it "should handle empty lists" do
      events = []
      expect(subject.get_events_by_day(events, work)).to eq([])
    end

    it "should handle events without event_time" do
      events = [{ }, { event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work)).to eq([{:year=>2013, :month=>8, :day=>5, :total=>1}])
    end
  end

  describe "get_events_by_month" do
    before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

    it "should handle events" do
      events = [{ event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }, { event_time: (Date.today - 1.week).to_datetime.utc.iso8601 }]
      expect(subject.get_events_by_month(events)).to eq([{ year: 2013, month: 8, total: 2 }])
    end

    it "should handle empty lists" do
      events = []
      expect(subject.get_events_by_month(events)).to eq([])
    end

    it "should handle events without event_time" do
      events = [{ }, { event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }]
      expect(subject.get_events_by_month(events)).to eq([{ year: 2013, month: 8, total: 1 }])
    end
  end
end
