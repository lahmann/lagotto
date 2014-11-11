# encoding: UTF-8

class SourceNotUpdatedError < Filter
  def run_filter(state)
    responses_by_agent = ApiResponse.filter(state[:id]).group(:agent_id).count
    responses = agent_ids.select { |agent_id| !responses_by_agent.key?(agent_id) }

    if responses.count > 0
      # send additional report, listing all stale agents by name
      report = Report.find_by_name("stale_agent_report")
      report.send_stale_agent_report(responses)

      responses = responses.map do |response|
        { agent_id: response,
          message: "Source not updated for 24 hours" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "agent_ids" }]
  end

  def source_ids
    config.agent_ids || Agent.active.where("name != ?", 'pmc').pluck(:id)
  end
end

module Exceptions
  class SourceNotUpdatedError < ApiResponseError; end
end
