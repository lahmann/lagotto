# encoding: UTF-8

require 'custom_error'
require 'timeout'

class AgentJob < Struct.new(:rs_ids, :agent_id)
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  include CustomError

  def enqueue(job)
    # keep track of when the article was queued up
    RetrievalStatus.update_all(["queued_at = ?", Time.zone.now], ["id in (?)", rs_ids])
  end

  def perform
    agent = Agent.find(agent_id)
    agent.work_after_check

    # Check that agent is working and we have workers for this agent
    # Otherwise raise an error and reschedule the job
    fail AgentInactiveError, "#{agent.display_name} is not in working state" unless agent.working?
    fail NotEnoughWorkersError, "Not enough workers available for #{agent.display_name}" unless agent.check_for_available_workers

    rs_ids.each do | rs_id |
      rs = RetrievalStatus.find(rs_id)

      # Track API response result and duration in api_responses table
      response = { article_id: rs.article_id, agent_id: rs.source_id, retrieval_status_id: rs_id }
      start_time = Time.zone.now
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(rs.perform_get_data)
        payload.merge!(response)
      end

      # observe rate-limiting settings
      sleep_interval = start_time + agent.job_interval - Time.zone.now
      sleep(sleep_interval) if sleep_interval > 0
    end
  end

  def error(job, exception)
    # don't create alert for these errors
    unless exception.kind_of?(AgentInactiveError) || exception.kind_of?(NotEnoughWorkersError)
      Alert.create(exception: "", class_name: exception.class.to_s, message: exception.message, agent_id: agent_id, level: Alert::WARN)
    end
  end

  def failure(job)
    # bring error into right format
    error = job.last_error.split("\n")
    message = error.shift
    exception = OpenStruct.new(backtrace: error)

    Alert.create(class_name: "DelayedJobError", message: "Failure in #{job.queue}: #{message}", exception: exception, agent_id: agent_id)
  end

  def after(job)
    agent = Agent.find(agent_id)
    RetrievalStatus.update_all(["queued_at = ?", nil], ["id in (?)", rs_ids])
    agent.wait_after_check
  end

  # override the default settings which are:
  # On failure, the job is scheduled again in 5 seconds + N ** 4, where N is the number of retries.
  # with the settings below we try 10 times within one hour, because we then queue jobs again anyway.
  def reschedule_at(time, attempts)
    case attempts
    when (0..4)
      interval = 1.minute
    when (5..6)
      interval = 5.minutes
    else
      interval = 10.minutes
    end
    time + interval
  end
end
