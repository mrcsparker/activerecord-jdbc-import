require 'bundler/setup'
require 'active_record'
require 'activerecord-jdbc-import'
require 'ffaker'

SQLITE_CONFIG = {
  :adapter => 'sqlite3',
  :database => 'spec/database.sqlite3'
}

ActiveRecord::Base.establish_connection(SQLITE_CONFIG)

class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products, :force => true do |t|
      t.string :code, :limit => 20
      t.string :name
      t.string :vendor
      t.float :price
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end

class Product < ActiveRecord::Base
  include ActiveRecord::Jdbc::Import
end
