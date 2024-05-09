class ElimConsexpcasoFeb24 < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_consexpcaso CASCADE;
      DROP VIEW IF EXISTS mcben1 CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW IF EXITS IF EXISTS mcben1 CASCADE;
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_consexpcaso CASCADE;
    SQL
  end
end
