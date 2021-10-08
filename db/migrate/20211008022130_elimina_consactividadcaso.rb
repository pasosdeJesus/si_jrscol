class EliminaConsactividadcaso < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_sjr_consactividadcaso;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_sjr_consactividadcaso;
    SQL
  end
end
