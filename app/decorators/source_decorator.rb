class SourceDecorator < Draper::Decorator
  delegate_all
  decorates_association :group

  def group
    object.group.name
  end

  def by_day
    { "with_events" => with_events_by_day_count,
      "without_events" => without_events_by_day_count,
      "not_updated" => articles_count - (with_events_by_day_count + without_events_by_day_count) }
  end

  def by_month
    { "with_events" => with_events_by_month_count,
      "without_events" => without_events_by_month_count,
      "not_updated" => articles_count - (with_events_by_month_count + without_events_by_month_count) }
  end
end
