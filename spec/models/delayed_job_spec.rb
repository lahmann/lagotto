require 'rails_helper'

describe DelayedJob, :type => :model do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  subject { FactoryGirl.create(:agent, run_at: Time.zone.now) }

  context "use background jobs" do
    let(:tasks) { FactoryGirl.create_list(:task, 10, agent_id: subject.id) }
    let(:task_ids) { tasks.map(&:id) }

    context "queue all works" do
      it "queue" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
      end

      it "with rate_limiting" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        subject.rate_limiting = 5
        expect(subject.queue_all_works).to eq(10)
      end

      it "with inactive agent" do
        subject.inactivate
        expect(subject).to be_inactive
        expect(subject.queue_all_works).to eq(0)
      end

      it "with disabled agent" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        expect(subject).to be_disabled
        expect(subject.queue_all_works).to eq(0)
      end

      # it "within time interval" do
      #   retrieval_statuses = FactoryGirl.create_list(:retrieval_status, 10, :with_work_published_today, agent_id: agent.id)
      #   task_ids = retrieval_statuses.map(&:id)

      #   Delayed::Job.stub(:enqueue).with(AgentJob.new(task_ids, agent.id), { queue: agent.name, run_at: Time.zone.now, priority: 2 })
      #   agent.queue_all_works({ start_date: Time.zone.now, end_date: Time.zone.now }).should == 10
      #   Delayed::Job.expects(:enqueue).with(AgentJob.new(task_ids, agent.id))
      # end

      it "outside time interval" do
        tasks = FactoryGirl.create_list(:task, 10, :with_work_published_today, agent_id: subject.id)
        task_ids = tasks.map(&:id)

        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works(start_date: Date.today - 2.days, end_date: Date.today - 2.days)).to eq(0)
      end
    end

    context "queue works" do
      it "queue" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
      end

      it "only stale works" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        task = FactoryGirl.create(:task, agent_id: subject.id, scheduled_at: Date.today + 1.day)
        expect(subject.queue_all_works).to eq(10)
      end

      it "not queued works" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        task = FactoryGirl.create(:task, agent_id: subject.id, queued_at: Time.zone.now)
        expect(subject.queue_all_works).to eq(10)
      end

      it "with rate-limiting" do
        rate_limiting = 5
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        subject.rate_limiting = rate_limiting
        expect(subject.queue_all_works).to eq(10)
      end

      it "with job_batch_size" do
        job_batch_size = 5
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids[0...job_batch_size], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids[job_batch_size..10], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        subject.job_batch_size = job_batch_size
        expect(subject.queue_all_works).to eq(10)
      end

      it "with inactive agent" do
        subject.inactivate
        expect(subject.queue_all_works).to eq(0)
        expect(subject).to be_inactive
      end

      it "with disabled agent" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
        expect(subject).to be_disabled
      end

      it "with waiting agent" do
        subject.wait
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
        expect(subject).to be_waiting
      end

      it "with too many failed queries" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        FactoryGirl.create_list(:notification, 10, agent_id: subject.id, updated_at: Time.zone.now - 10.minutes)
        subject.max_failed_queries = 5
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
        expect(subject).not_to be_disabled
      end

      it "with queued jobs" do
        allow(Delayed::Job).to receive(:count).and_return(1)
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_all_works).to eq(10)
      end
    end

    context "queue work jobs" do
      it "multiple works" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_work_jobs(task_ids)).to eq(10)
      end

      it "single work" do
        task = FactoryGirl.create(:task, agent_id: subject.id)
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new([task.id], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(AgentJob.new([task.id], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_work_jobs([task.id])).to eq(1)
      end
    end

    context "job callbacks" do
      it "perform callback" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_work_jobs(task_ids)).to eq(10)
      end

      it "perform callback without workers" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        subject.workers = 0
        expect(subject.queue_work_jobs(task_ids)).to eq(10)
      end

      it "perform callback without enough workers" do
        job_batch_size = 5
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids[0...job_batch_size], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids[job_batch_size..10], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(AgentJob.new(task_ids[0...job_batch_size], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(AgentJob.new(task_ids[job_batch_size..10], subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        subject.job_batch_size = job_batch_size
        subject.workers = 1
        expect(subject.queue_work_jobs(task_ids)).to eq(10)
      end

      it "after callback" do
        allow(Delayed::Job).to receive(:enqueue).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:after).with(AgentJob.new(task_ids, subject.id), queue: subject.name, run_at: Time.zone.now, priority: 5)
        expect(subject.queue_work_jobs(task_ids)).to eq(10)
      end
    end

    describe "check for failures" do

      let(:class_name) { "Net::HTTPRequestTimeOut" }
      before(:each) do
        FactoryGirl.create_list(:notification, 10, agent_id: subject.id, updated_at: Time.zone.now - 10.minutes, class_name: class_name)
      end

      it "few failed queries" do
        expect(subject.check_for_failures).to be false
      end

      it "too many failed queries" do
        subject.max_failed_queries = 5
        expect(subject.check_for_failures).to be true
      end

      it "too many failed queries but they are too old" do
        subject.max_failed_queries = 5
        subject.max_failed_query_time_interval = 500
        expect(subject.check_for_failures).to be false
      end
    end
  end
end
