require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'magic_numbers'
require 'test/unit'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

$old_stdout = nil

def setup_db
  $old_stdout = $stdout
  $stdout = StringIO.new

  ActiveRecord::Schema.define(:version => 1) do
    create_table :foos do |t|
      t.column :state, :integer
      t.column :roles, :integer
    end
  end

  $stdout = $old_stdout
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
