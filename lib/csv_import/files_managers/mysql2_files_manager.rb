module CsvImport
  module FilesManagers
    class Mysql2FilesManager < AbstractFilesManager

      def csv_file_name_for_new_records
        @persister.klass.table_name
      end

      def csv_file_name_for_present_records
        @persister.present_records_tmp_table_name
      end

    end
  end
end
