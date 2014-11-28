module CustomError
  # agent is either inactive or disabled
  class AgentInactiveError < StandardError; end

  # we have received too many errors (and will disable the agent)
  class TooManyErrorsByAgentError < StandardError; end

  # we don't have enough available workers for this agent
  class NotEnoughWorkersError < StandardError; end

  # something went wrong with Delayed Job
  class DelayedJobError < StandardError; end

  # Default filter error
  class ApiResponseError < StandardError; end
end
