module Dateable
  extend ActiveSupport::Concern

  included do
    def get_date_parts(iso8601_time)
      year, month, day = split_date(iso8601_time)
      get_date_parts_from_parts(year, month, day)
    end

    def split_date(iso8601_time)
      str = iso8601_time.to_s

      # return nil if they are nil or 0, otherwise return integer
      year = str[0..3].nil? || str[0..3].to_i == 0 ? nil : str[0..3].to_i
      month = str[5..6].nil? || str[5..6].to_i == 0 ? nil : str[5..6].to_i
      day = str[8..9].nil? || str[8..9].to_i == 0 ? nil : str[8..9].to_i

      [year, month, day]
    end

    def get_date_parts_from_parts(year, month = nil, day = nil)
      return nil if year.nil?

      { 'date-parts' => [[year, month, day].reject(&:nil?)] }
    end
  end
end
