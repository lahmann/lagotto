require 'rails_helper'

describe AgentJob do

  let(:task) { FactoryGirl.create(:task) }
  let(:agent) { FactoryGirl.create(:agent) }
  let(:task_id) { "#{task.agent.name}:#{task.article.doi_escaped}" }
  let(:job) { FactoryGirl.create(:delayed_job) }

  subject { AgentJob.new([task.id], agent.id) }

  before(:each) { subject.put_lagotto_database }
  after(:each) { subject.delete_lagotto_database }

  context "error" do
    it "should create an notification on error" do
      exception = StandardError.new
      subject.error(job, exception)

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("StandardError")
      expect(notification.agent_id).to eq(agent.id)
    end

    it "should not create an notification if agent is not in working state" do
      exception = AgentInactiveError.new
      subject.error(job, exception)

      expect(Notification.count).to eq(0)
    end

    it "should not create an notification if not enough workers available for agent" do
      exception = NotEnoughWorkersError.new
      subject.error(job, exception)

      expect(Notification.count).to eq(0)
    end
  end

  context "failure" do
    it "should not create an notification if not enough workers available for agent" do
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      error = File.read(fixture_path + 'delayed_job_failure.txt')
      job.last_error = error
      error = error.split("\n")
      # we are filtering the backtrace
      trace = "/var/www/alm/releases/20140416153936/lib/agent_job.rb:45:in `perform'\nscript/delayed_job:5:in `<main>'"

      subject.failure(job)

      expect(Notification.count).to eq(0)
    end
  end

  context "after" do
    # TODO: needs further work
    it "should clean up after the job" do
      subject.after(job)

      expect(agent).to be_waiting
    end
  end

  context "reschedule jobs" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }
    let(:time) { Time.now - 30.minutes }

    it "should reschedule a job after 0 attempts" do
      expect(subject.reschedule_at(time, 0)).to eq(time + 1.minute)
    end

    it "should reschedule a job after 5 attempts" do
      expect(subject.reschedule_at(time, 5)).to eq(time + 5.minutes)
    end

    it "should reschedule a job after 8 attempts" do
      expect(subject.reschedule_at(time, 8)).to eq(time + 10.minutes)
    end
  end
end
