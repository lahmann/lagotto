class EventDecorator < Draper::Decorator
  delegate_all

  def source
    object.source.name
  end
end
