require 'rails_helper'

describe Task, :type => :model do
  before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:agent) }

  describe "use stale_at" do
    subject { FactoryGirl.create(:task) }

    it "stale_at should be a datetime" do
      expect(subject.stale_at).to be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      expect(subject.stale_at - Time.zone.now).to be > 0
    end

    it "stale_at should be after work publication date" do
      expect(subject.stale_at - subject.work.published_on.to_datetime).to be > 0
    end
  end

  describe "staleness intervals" do
    it "published a day ago" do
      date = Date.today - 1.day
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      task = FactoryGirl.create(:task, :work => work)
      duration = task.agent.staleness[0]
      expect(task.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Date.today - 8.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      task = FactoryGirl.create(:task, :work => work)
      duration = task.agent.staleness[1]
      expect(task.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Date.today - 32.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      task = FactoryGirl.create(:task, :work => work)
      duration = task.agent.staleness[2]
      expect(task.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Date.today - 370.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      task = FactoryGirl.create(:task, :work => work)
      duration = task.agent.staleness[3]
      expect(task.stale_at - Time.zone.now).to be_within(0.15 * duration).of(duration)
    end
  end

  describe "CouchDB" do
    let!(:source) { FactoryGirl.create(:source, name: "citeulike") }
    let(:task) { FactoryGirl.create(:task) }
    let(:task_id) { "#{task.agent.name}:#{task.work.doi_escaped}" }
    let(:error) { { "error" => "not_found", "reason" => "deleted" } }

    before(:each) do
      subject.put_lagotto_database
    end

    after(:each) do
      subject.delete_lagotto_database
    end

    it "should perform and get data" do
      stub = stub_request(:get, task.agent.get_query_url(task.work))
             .to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = task.perform_get_data

      task_result = task.get_lagotto_data(task_id)
      # rs_result.should include("agent" => task.agent.name,
      #                          "doi" => task.work.doi,
      #                          "doc_type" => "current",
      #                          "_id" =>  "#{task.agent.name}:#{task.work.doi}")
      # rh_result = task.get_lagotto_data(rh_id)
      # rh_result.should include("agent" => task.agent.name,
      #                          "doi" => task.work.doi,
      #                          "doc_type" => "history",
      #                          "_id" => "#{rh_id}")

      # task.work.destroy
      # subject.get_lagotto_data(rs_id).should eq(error)
      # subject.get_lagotto_data(rh_id).should eq(error)
    end
  end
end
