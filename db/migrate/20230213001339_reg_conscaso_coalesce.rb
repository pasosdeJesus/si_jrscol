class RegConscasoCoalesce < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_conscaso CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_conscaso CASCADE;
    SQL
  end

end
