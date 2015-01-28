require 'rails_helper'

describe Source do

  describe "get_event_metrics" do
    describe "citations" do
      let(:citations) { 12 }
      let(:total) { citations }
      let(:output) do
        { :pdf => nil,
          :html => nil,
          :shares => nil,
          :groups => nil,
          :comments => nil,
          :likes => nil,
          :citations => citations,
          :total => total }
      end

      it 'should return citations' do
        result = subject.get_event_metrics(citations: citations)
        expect(result).to eq(output)
      end

      it 'should handle strings' do
        result = subject.get_event_metrics(citations: "#{citations}")
        expect(result).to eq(output)
      end

      it 'should report a separate total value' do
        result = subject.get_event_metrics(citations: citations, total: 14)
        expect(result[:citations]).to eq(citations)
        expect(result[:total]).to eq(14)
      end
    end
  end

  describe "get_sum" do
    it 'should add values' do
      items = [{ "html" => 1 }, { "html" => 4}]
      result = subject.get_sum(items, "html")
      expect(result).to eq(5)
    end

    it 'should add nested values' do
      items = [{ "stats" => { "html" => 1 }}, { "stats" => { "html" => 4}}]
      result = subject.get_sum(items, "stats", "html")
      expect(result).to eq(5)
    end

    it 'should handle nil' do
      result = subject.get_sum(nil, "html")
      expect(result).to eq(0)
    end
  end

  describe "get_iso8601_from_time" do
    it 'should get the time' do
      result = subject.get_iso8601_from_time("2014-12-04")
      expect(result).to eq("2014-12-04T00:00:00Z")
    end

    it 'should handle nil' do
      result = subject.get_iso8601_from_time(nil)
      expect(result).to be_nil
    end
  end

  describe "get_iso8601_from_epoch" do
    it 'should get the time' do
      result = subject.get_iso8601_from_epoch("1357632000")
      expect(result).to eq("2013-01-08T08:00:00Z")
    end

    it 'should handle nil' do
      result = subject.get_iso8601_from_epoch(nil)
      expect(result).to be_nil
    end
  end
end
