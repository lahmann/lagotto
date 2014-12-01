module Validateable
  extend ActiveSupport::Concern

  included do
    # Use values from year, month, day for published_on
    # Uses  "01" for month and day if they are missing
    def validate_published_on
      date_parts = [year, month, day].reject(&:blank?)
      published_on = Date.new(*date_parts)
      if published_on > Time.zone.now.to_date
        errors.add :published_on, "is a date in the future"
      elsif published_on < Date.new(1650)
        errors.add :published_on, "is before 1650"
      else
        write_attribute(:published_on, published_on)
      end
    rescue ArgumentError
      errors.add :published_on, "is not a valid date"
    end

    def sanitize_title
      self.title = ActionController::Base.helpers.sanitize(title)
    end
  end
end
