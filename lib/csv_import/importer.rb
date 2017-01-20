require 'csv_import/persisters/abstract_persister'

module CsvImport
  class Importer

    def initialize(options = {})
      @options = self.class.default_options.deep_merge(options)
      @initialized_at = Time.zone.now
      @classes_persisters = {}

      if block_given?
        yield self
        persist!
      end

    end

    def add(record)
      persister = persister_for_class(record.class) 
      persister.add(record)
    end

    def persist!
      persisters = @classes_persisters.values
      persisters.each(&:persist!)
    end

    def imported_records
      if @classes_persisters.blank?
        ApplicationRecord.none
      elsif @classes_persisters.count == 1
        imported_records_for(@classes_persisters.first[0])
      else
        raise "Must use imported_records_for_class(klass) as there are more than one type of classes whose records are imported"
      end
    end

    def imported_records_for(klass)
      persister_for_class(klass).imported_records
    end

    private

    def persister_for_class(klass)
      @classes_persisters[klass] ||= Persisters::Factory.new_persister(klass, @options.merge(initialized_at: @initialized_at)) 
    end

    def self.default_options
      {
        terminator: "~|",
        csv_files_dir: "#{Rails.root}/tmp",
        validate: false,
        delete_csv_files: true
      }
    end
  end
end 