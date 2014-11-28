class NotificationDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def level
    object.human_level_name
  end

  def agent
    agent_id ? object.agent.name : nil
  end

  def source
    source_id ? object.source.name : nil
  end

  def article
    article_id ? object.article.uid : nil
  end
end
