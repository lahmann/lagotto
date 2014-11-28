class GroupDecorator < Draper::Decorator
  delegate_all

  def id
    name
  end

  def sources
    object.sources.active.map { |source| source.name }
  end

  def agents
    object.agents.visible.map { |agent| agent.name }
  end
end
