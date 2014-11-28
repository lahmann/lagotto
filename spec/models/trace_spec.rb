require 'rails_helper'

describe Trace, :type => :model do
  before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }

  describe "retrieval_histories" do
    let(:trace) { FactoryGirl.create(:trace, :with_crossref_histories) }

    it "should get past events by month" do
      expect(trace.get_past_events_by_month).to eq([{:year=>2013, :month=>4, :total=>800}, {:year=>2013, :month=>5, :total=>820}, {:year=>2013, :month=>6, :total=>870}, {:year=>2013, :month=>7, :total=>910}, {:year=>2013, :month=>8, :total=>950}])
    end
  end
end
