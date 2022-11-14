class RehaceUltimaatencioAux < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS sivel2_sjr_ultimaatencion_aux CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW IF EXISTS sivel2_sjr_ultimaatencion_aux CASCADE;
    SQL
  end
end
