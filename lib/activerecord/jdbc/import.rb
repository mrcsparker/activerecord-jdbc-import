require "activerecord/jdbc/import/version"

module Activerecord
  module Jdbc
    module Import
      extend ActiveSupport::Concern

      included do

      end

      private

      def self.import(models)
        return unless models.size > 0

        conn = klass.connection.jdbc_connection

        insert_sql = models.first.to_prepared_sql

        pstmt = conn.prepareStatement(insert_sql)

        conn.setAutoCommit(false)

        models.each do |model|

          i = 1
          model.attributes.each_pair do |key, value|
            model_type = klass.columns_hash[key].type

            if model_type == :integer
              pstmt.setInt(i, value.to_i)
            elsif key.to_s.downcase == 'week_date'
              pstmt.setString(i, value.to_date.strftime("%Y/%m/%d"))
            elsif model_type == :string and value.nil?
              pstmt.setString(i, nil)
            else
              pstmt.setString(i, value.to_s)
            end

            i += 1
          end

          pstmt.addBatch()
        end

        pstmt.executeBatch()

        conn.commit()

        conn.setAutoCommit(true)
      end

      def to_prepared_sql
        conn = self.connection

        quoted_columns = []
        quoted_values = []
        attributes_with_values = self.send(:arel_attributes_values, true, true)
        attributes_with_values.each_pair do |key,value|  
          quoted_columns << conn.quote_column_name(key.name)
          quoted_values << '?'
        end

        "INSERT INTO #{self.class.quoted_table_name} " +
          "(#{quoted_columns.join(', ')}) "  +
          "VALUES (#{quoted_values.join(', ')});"
      end
    end
  end
end
