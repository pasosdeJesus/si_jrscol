class RegeneraConsgiffm202003 < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consgifmm;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consgifmm;
    SQL
  end
end
