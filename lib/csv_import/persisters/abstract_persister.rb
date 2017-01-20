require 'csv_import/converters/abstract_converter'
require 'csv_import/files_managers/abstract_files_manager'

module CsvImport
  module Persisters

    class Factory
      def self.new_persister(klass, options = {})
        persister_class = Persisters.const_get("#{ActiveRecord::Base.connection_config[:adapter].camelize}Persister")
        persister_class.new(klass, options)
      end
    end

    class AbstractPersister

      attr_accessor :klass

      def initialize(klass, options = {})
        @klass = klass
        @options = options

        @files_manager = FilesManagers::Factory.new_files_manager(self, @options.slice(:csv_files_dir, :delete_csv_files))
        @converter = Converters::Factory.concrete_converter
        
        @csv_columns = {}
        @csv_columns[:new_records] = @klass.new.attribute_names - ["id".freeze]
        @csv_columns[:present_records] = @klass.new.attribute_names
      end

      def add(record)
        if !@options[:validate] || record.valid?
          prepare_record(record)
          csv_row = @converter.csv_values(record).join(@options[:terminator]).gsub("\n", "\\n")
          record_type = record.new_record? ? :new_record : :present_record
          @files_manager.write("#{csv_row}\n", record_type)
        end
      end

      def persist!
        @files_manager.close
        create_new_records
        update_present_records 
        @files_manager.clear
      end



      # methods to be implemented in concrete subclasses
      def create_new_records
        raise NotImplementedError
      end

      def update_present_records
        raise NotImplementedError
      end

      def imported_records
        raise NotImplementedError
      end
      
      private

        def prepare_record(record)
          set_time_stamps_for(record)
        end

        def set_time_stamps_for(record)
          record.updated_at = @options[:initialized_at] if record.attribute_names.include?("updated_at".freeze)
          record.created_at = @options[:initialized_at] if record.new_record? && record.attribute_names.include?("created_at".freeze)
        end

        def csv_columns_for(records_type)
          @csv_columns[records_type]
        end

    end
  end
end

require 'csv_import/persisters/mysql2_persister'