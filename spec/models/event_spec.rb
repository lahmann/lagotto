require 'rails_helper'

describe Event, :type => :model do

  let(:event) { FactoryGirl.create(:event) }

  subject { event }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  context "validate date" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it 'validate date' do
      event = FactoryGirl.build(:event)
      expect(event).to be_valid
    end

    it 'validate date with missing day' do
      event = FactoryGirl.build(:event, day: nil)
      expect(event).to be_valid
    end

    it 'validate date with missing month and day' do
      event = FactoryGirl.build(:event, month: nil, day: nil)
      expect(event).to be_valid
    end

    it 'don\'t validate date with missing year, month and day' do
      event = FactoryGirl.build(:event, year: nil, month: nil, day: nil)
      expect(event).not_to be_valid
      expect(event.errors.messages).to eq(year: ["is not a number"], published_on: ["is before 1650"])
    end

    it 'don\'t validate wrong date' do
      event = FactoryGirl.build(:event, month: 2, day: 30)
      expect(event).not_to be_valid
      expect(event.errors.messages).to eq(published_on: ["is not a valid date"])
    end

    it 'don\'t validate date in the future' do
      date = Date.today + 1.day
      event = FactoryGirl.build(:event, year: date.year, month: date.month, day: date.day)
      expect(event).not_to be_valid
      expect(event.errors.messages).to eq(published_on: ["is a date in the future"])
    end

    it 'published_on' do
      event = FactoryGirl.create(:event)
      date = Date.new(event.year, event.month, event.day)
      expect(event.published_on).to eq(date)
    end

    it 'issued' do
      event = FactoryGirl.create(:event)
      expect(event.issued).to eq("date-parts" => [[event.year, event.month, event.day]])
    end

    it 'issued year month' do
      event = FactoryGirl.create(:event, year: 2013, month: 2, day: nil)
      expect(event.issued).to eq("date-parts"=>[[2013, 2]])
    end

    it 'issued year' do
      event = FactoryGirl.create(:event, year: 2013, month: nil, day: nil)
      expect(event.issued).to eq("date-parts"=>[[2013]])
    end
  end

  it 'sanitize title' do
    event = FactoryGirl.create(:event, title: "<italic>Test</italic>")
    expect(event.title).to eq("Test")
  end

end
