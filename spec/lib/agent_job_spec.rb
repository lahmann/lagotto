require 'spec_helper'

describe AgentJob do

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:agent) { FactoryGirl.create(:agent) }
  let(:rs_id) { "#{retrieval_status.agent.name}:#{retrieval_status.article.doi_escaped}" }
  let(:job) { FactoryGirl.create(:delayed_job) }

  subject { AgentJob.new([retrieval_status.id], agent.id) }

  before(:each) { subject.put_lagotto_database }
  after(:each) { subject.delete_lagotto_database }

  context "error" do
    it "should create an alert on error" do
      exception = StandardError.new
      subject.error(job, exception)

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("StandardError")
      alert.agent_id.should == agent.id
    end

    it "should not create an alert if agent is not in working state" do
      exception = SourceInactiveError.new
      subject.error(job, exception)

      Alert.count.should == 0
    end

    it "should not create an alert if not enough workers available for agent" do
      exception = NotEnoughWorkersError.new
      subject.error(job, exception)

      Alert.count.should == 0
    end
  end

  context "failure" do
    it "should create an alert on failure" do
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      error = File.read(fixture_path + 'delayed_job_failure.txt')
      job.last_error = error
      error = error.split("\n")
      # we are filtering the backtrace
      trace = "/var/www/alm/releases/20140416153936/lib/agent_job.rb:45:in `perform'\nscript/delayed_job:5:in `<main>'"

      subject.failure(job)

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("DelayedJobError")
      alert.message.should eq("Failure in #{job.queue}: #{error.shift}")
      alert.trace.should eq(trace)
      alert.agent_id.should == agent.id
    end
  end

  context "after" do
    # TODO: needs further work
    it "should clean up after the job" do
      subject.after(job)

      agent.should be_waiting
    end
  end

  context "reschedule jobs" do
    before(:each) { Time.stub(:now).and_return(Time.mktime(2013, 9, 5)) }
    let(:time) { Time.now - 30.minutes }

    it "should reschedule a job after 0 attempts" do
      subject.reschedule_at(time, 0).should eq(time + 1.minute)
    end

    it "should reschedule a job after 5 attempts" do
      subject.reschedule_at(time, 5).should eq(time + 5.minutes)
    end

    it "should reschedule a job after 8 attempts" do
      subject.reschedule_at(time, 8).should eq(time + 10.minutes)
    end
  end
end
