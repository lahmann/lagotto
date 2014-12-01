require 'rails_helper'

describe Event do

  context "split_date" do
    it "can split date into parts" do
      date = "2014-06-23"
      result = subject.split_date(date)
      expect(result).to eq([2014, 6, 23])
    end

    it "can handle partial dates" do
      date = "2014-06-00"
      result = subject.split_date(date)
      expect(result).to eq([2014, 6, nil])
    end
  end

  context "get_date_parts_from_parts" do
    it "can generate date-parts array" do
      year, month, day = 2014, 6, 23
      result = subject.get_date_parts_from_parts(year, month, day)
      expect(result).to eq("date-parts" => [[2014, 6, 23]])
    end

    it "can generate date-parts array for year-only" do
      year = 2014
      result = subject.get_date_parts_from_parts(year)
      expect(result).to eq("date-parts" => [[2014]])
    end
  end

  context "get_date_parts" do
    it "can split date into parts" do
      date = "2014-06-23"
      result = subject.get_date_parts(date)
      expect(result).to eq("date-parts"=>[[2014, 6, 23]])
    end

    it "can handle partial dates" do
      date = "2014-06-00"
      result = subject.get_date_parts(date)
      expect(result).to eq("date-parts"=>[[2014, 6]])
    end
  end
end
