module Overbonds
  module OutputFormatter
    extend ActiveSupport::Concern

    SPREAD_FORMAT = '%.2f%'.freeze

    def self.to_csv(headers, rows)
      CSV.generate(headers: :first_row) do |csv|
        csv << headers
        rows.each do |row|
          csv << with_printable_spread(row)
        end
      end
    end

    def self.with_printable_spread(row)
      row[-1] = sprintf(SPREAD_FORMAT, row.last)
      row
    end
  end
end