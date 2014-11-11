class AgentDecorator < Draper::Decorator
  delegate_all
  decorates_association :group

  def group
    object.group.name
  end

  def jobs
    { "working" => working_count,
      "pending" => pending_count }
  end

  def responses
    { "count" => response_count,
      "average" => average_count,
      "maximum" => maximum_count }
  end

  def status
    { "refreshed" => articles_count - (stale_count + queued_count),
      "queued" => queued_count,
      "stale" => stale_count }
  end
end
