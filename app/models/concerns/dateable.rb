module Dateable
  extend ActiveSupport::Concern

  included do
    def get_date_parts(iso8601_time)
      return nil if iso8601_time.nil?

      year = iso8601_time[0..3].to_i
      month = iso8601_time[5..6].to_i
      day = iso8601_time[8..9].to_i
      { 'date-parts' => [[year, month, day]] }
    end

    def get_date_parts_from_parts(year, month = nil, day = nil)
      { 'date-parts' => [[year, month, day].reject(&:blank?)] }
    end
  end
end
