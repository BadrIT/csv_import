module CsvImport
  module FilesManagers

    class Factory
      def self.new_files_manager(persister, options = {})
        files_manager_class = FilesManagers.const_get("#{ActiveRecord::Base.connection_config[:adapter].camelize}FilesManager")
        files_manager_class.new(persister, options)
      end
    end

    class AbstractFilesManager

      def initialize(persister, options = {})
        @options = options
        @persister = persister
        @csv_files_sub_dir = "#{options[:csv_files_dir]}/tmp_#{Time.zone.now.to_s(:db)}_#{SecureRandom.hex[0..10]}"
        FileUtils.mkdir_p(@csv_files_sub_dir)

        @csv_files = {
          new_records: File.new("#{@csv_files_sub_dir}/#{csv_file_name_for_new_records}.txt", 'w'),
          present_records: File.new("#{@csv_files_sub_dir}/#{csv_file_name_for_present_records}.txt", 'w')
        }

      end

      def csv_file_for(records_type)
        records_type == :new_records ? @csv_files[:new_records] : @csv_files[:present_records]
      end

      def write(data, record_type)
        records_type = record_type.to_s.pluralize.to_sym
        @csv_files[records_type].write(data)
      end

      def close
        @csv_files.each{|records_type, csv_file| csv_file.close}
      end

      def clear
        delete_csv_files if @options[:delete_csv_files]
      end



      # methods to be implemented in concrete subclasses
      def csv_file_name_for_new_records
        raise NotImplementedError
      end

      def csv_file_name_for_present_records
        raise NotImplementedError
      end

      private

      def delete_csv_files
        FileUtils.rm_rf(@csv_files_sub_dir)
      end

    end
  end
end

require 'csv_import/files_managers/mysql2_files_manager'
