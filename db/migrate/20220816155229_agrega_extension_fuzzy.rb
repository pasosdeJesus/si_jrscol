class AgregaExtensionFuzzy < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    SQL
  end
  def down
    execute <<-SQL
      DROP EXTENSION fuzzystrmatch;
    SQL
  end
end
