class AlertDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def level
    model.human_level_name
  end

  def alert
    alert_id ? model.alert.name : nil
  end

  def article
    article_id ? model.article.uid : nil
  end
end
