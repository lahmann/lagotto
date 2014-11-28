class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def publisher
    publisher_id
  end

  def reports
    object.reports.map { |report| report.name }
  end
end
