module CsvImport
  module Converters

    class Factory
      def self.concrete_converter
        Converters.const_get("#{ActiveRecord::Base.connection_config[:adapter].camelize}Converter")
      end
    end

    class AbstractConverter

      class << self

        def csv_values(record)
          columns = record.attribute_names
          columns -= ["id".freeze] if record.new_record?
          attributes = record.instance_eval("@attributes")
          columns.map do |column|
            self.csv_value(attributes[column])
          end
        end

        def csv_value(attribute)
          if attribute.value.nil?
            csv_null_value
          else
            ActiveRecord::Base.connection.quote(attribute.value_for_database)
          end
        end

       # methods to be implemented in concrete subclasses
        def csv_null_value
          raise NotImplementedError
        end

      end

    end
  end
end

require 'csv_import/converters/mysql2_converter'