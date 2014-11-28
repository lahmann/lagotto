class AgentDecorator < Draper::Decorator
  delegate_all

  def id
    name
  end

  def source
    object.source
  end

  def group
    object.group.name
  end

  def status
    human_state_name
  end

  def articles
    { "refreshed" => works_count - (stale_count + queued_count),
      "queued" => queued_count,
      "stale" => stale_count }
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
end
