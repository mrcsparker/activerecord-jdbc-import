require "active_record/jdbc/import/version"
require 'active_support'

module ActiveRecord
  module Jdbc
    module Import
      extend ActiveSupport::Concern

      included do

      end

      # Code here is ugly.
      # Going to clean up as soon as the whole idea is worked out.

      module ClassMethods

        def import_infile(models)
          return unless models.size > 0

          start = Time.now

          CSV.open("/tmp/upload.csv", "w") do |row|

            row << models.first.keys.map { |a| a.to_s }

            models.each do |model|
              row << model.values
            end
          end

          sql = []
          sql << "LOAD DATA INFILE '/tmp/upload.csv'"
          sql << "INTO TABLE #{self.table_name}"
          sql << "FIELDS TERMINATED BY ','"
          sql << "OPTIONALLY ENCLOSED BY '\"'"
          sql << "LINES TERMINATED BY '\\n'"
          sql << "IGNORE 1 LINES"
          sql << "(#{models.first.keys.map { |a| a.to_s }.join(",")});"

          self.connection.execute(sql.join(" "))

          p "Wrote tempfile: #{Time.now - start}"

        end

        def import(models)
          return unless models.size > 0

          conn = self.connection.jdbc_connection

          o = self.new
          insert_sql = o.to_prepared_sql
          ordered_columns = o.ordered_columns

          pstmt = conn.prepareStatement(insert_sql)

          conn.setAutoCommit(false)

          if models.first.is_a? Hash
            models.each do |model|
              i = 1
              ordered_columns.each do |key|
                next if key.to_s == 'id'
                next if key.to_s == 'created_at'
                next if key.to_s == 'updated_at'

                column_type = self.columns_hash[key.to_s].type
                value = model[key.to_sym]

                if column_type == :integer and value.nil?
                  pstmt.setInt(i, nil)
                elsif column_type == :integer
                  pstmt.setInt(i, value.to_i)
                elsif key.to_s.downcase == 'week_date'
                  pstmt.setString(i, value.to_date.strftime("%Y/%m/%d"))
                elsif column_type == :string and value.nil?
                  pstmt.setString(i, nil)
                else
                  pstmt.setString(i, value.to_s)
                end
                i += 1
              end
              pstmt.addBatch()
            end
          else
            models.each do |model|
              i = 1
              model.attributes.each_pair do |key, value|
                next if key.to_s == 'id'
                next if key.to_s == 'created_at'
                next if key.to_s == 'updated_at'

                column_type = self.columns_hash[key.to_s].type
                if column_type == :integer and value.nil?
                  pstmt.setInt(i, nil)
                elsif column_type == :integer
                  pstmt.setInt(i, value.to_i)
                elsif key.to_s.downcase == 'week_date'
                  pstmt.setString(i, value.to_date.strftime("%Y/%m/%d"))
                elsif column_type == :string and value.nil?
                  pstmt.setString(i, nil)
                else
                  pstmt.setString(i, value.to_s)
                end
                i += 1
              end
              pstmt.addBatch()
            end
          end

          pstmt.executeBatch()

          conn.commit()

          conn.setAutoCommit(true)
        end
      end

      def ordered_columns
        @ordered_columns
      end

      def to_prepared_sql
        conn = self.connection

        at_date = DateTime.now

        quoted_columns = []
        quoted_values = []
        @ordered_columns = []
        attributes_with_values = self.send(:arel_attributes_values, true, true)
        attributes_with_values.each_pair do |key,value|
          next if key.name.to_s == 'id'
          quoted_columns << conn.quote_column_name(key.name)
          if key.name.to_s == 'created_at' or key.name.to_s == 'updated_at'
            quoted_values << "'#{at_date.to_s(:db)}'"
          else
            @ordered_columns << key.name.to_s
            quoted_values << '?'
          end
        end

        "INSERT INTO #{self.class.quoted_table_name} " +
          "(#{quoted_columns.join(', ')}) "  +
          "VALUES (#{quoted_values.join(', ')})"
      end

    end
  end
end
