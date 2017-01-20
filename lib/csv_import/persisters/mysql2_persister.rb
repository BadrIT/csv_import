module CsvImport
  module Persisters
    class Mysql2Persister < AbstractPersister

      def create_new_records
        load_data_in_file(@files_manager.csv_file_for(:new_records), @klass.table_name, escape_reserved_keywords(csv_columns_for(:new_records)))
        build_inserted_new_records_statistics
      end

      def update_present_records
        ActiveRecord::Base.connection.execute("CREATE TABLE #{present_records_tmp_table_name} LIKE #{@klass.table_name};")
        load_data_in_file(@files_manager.csv_file_for(:present_records), present_records_tmp_table_name, escape_reserved_keywords(csv_columns_for(:present_records)))
        set_fields = escape_reserved_keywords(csv_columns_for(:new_records)).map{|field| "#{@klass.table_name}.#{field}=#{present_records_tmp_table_name}.#{field}"}.join(',')
        ActiveRecord::Base.connection.execute("UPDATE #{@klass.table_name} INNER JOIN #{present_records_tmp_table_name} ON #{@klass.table_name}.id = #{present_records_tmp_table_name}.id SET #{set_fields}")
        ActiveRecord::Base.connection.execute("DROP TABLE #{present_records_tmp_table_name}")
      end

      def imported_records
        klass.unscoped.where("id >= ? AND id < ?", @first_inserted_new_record_id, @inserted_new_records_count + @first_inserted_new_record_id)
      end

      # the name of the tmp table created to hold intermediate rows, which are meant
      # for update process
      def present_records_tmp_table_name
        # long table names are not valid in mysql
        @present_records_tmp_table_name ||= "temp_#{@klass.table_name}_#{Time.zone.now.to_s(:time).gsub(/-| |:/,'_')}"[0..50] + "_#{SecureRandom.hex[0..10]}"
      end

      private

        def load_data_in_file(file, table, columns_ordered)
          ActiveRecord::Base.connection.execute("LOAD DATA LOCAL INFILE '#{Shellwords.escape(file.path)}' INTO TABLE #{table} FIELDS TERMINATED BY '#{@options[:terminator]}' OPTIONALLY ENCLOSED BY \"'\" (#{columns_ordered.join(',')})")
        end

        def build_inserted_new_records_statistics
          @inserted_new_records_count = ActiveRecord::Base.connection.raw_connection.affected_rows
          @first_inserted_new_record_id = ActiveRecord::Base.connection.execute("SELECT last_insert_id();").to_a.first.first
        end

        def escape_reserved_keywords(columns)
          columns.map{|column| "`#{column}`"}
        end
      
    end
  end
end 