require 'rails_helper'

describe "filter:all" do
  include_context "rake"

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  context "found no errors" do

    before do
      FactoryGirl.create(:change)
      FactoryGirl.create(:decreasing_event_count_error)
    end

    let(:output) { "Found 0 decreasing event count errors" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end

  context "resolve all changes" do

    before do
      FactoryGirl.create(:change)
    end

    let(:output) { "Resolved 1 change" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end

  context "report decreasing event count errors" do

    before do
      FactoryGirl.create(:change, previous_count: 12)
      FactoryGirl.create(:decreasing_event_count_error)
    end

    let(:output) { "Found 1 decreasing event count error" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end

  context "report increasing event count errors" do

    before do
      FactoryGirl.create(:change, event_count: 3600)
      FactoryGirl.create(:increasing_event_count_error)
    end

    let(:output) { "Found 1 increasing event count error" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end

  context "report work not updated errors" do

    before do
      FactoryGirl.create(:change, event_count: nil, update_interval: 42)
      FactoryGirl.create(:work_not_updated_error)
    end

    let(:output) { "Found 1 work not updated error" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end

  context "report source not updated errors" do

    before do
      source = FactoryGirl.create(:source)
      FactoryGirl.create(:source, name: "mendeley")
      FactoryGirl.create(:change, source_id: source.id)
      FactoryGirl.create(:source_not_updated_error)
      FactoryGirl.create(:stale_source_report_with_admin_user)
    end

    let(:output) { "Found 1 source not updated error" }

    it "should run the rake task" do
      expect(capture_stdout { subject.invoke }).to include(output)
    end
  end
end

describe "filter:unresolve" do
  include_context "rake"

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  before do
    FactoryGirl.create(:change, unresolved: false)
  end

  let(:output) { "Unresolved 1 change" }

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to include(output)
  end
end
