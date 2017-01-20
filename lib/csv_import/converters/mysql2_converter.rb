module CsvImport
  module Converters
    class Mysql2Converter < AbstractConverter

      class << self
        def csv_null_value
          '\N'.freeze
        end
      end
    end
  end
end