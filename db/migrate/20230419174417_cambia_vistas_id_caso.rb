class CambiaVistasIdCaso < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS ultimodesplazamiento CASCADE;
      DROP VIEW IF EXISTS cvp2 CASCADE;
      DROP VIEW IF EXISTS cvp1 CASCADE;
      DROP VIEW IF EXISTS cben1 CASCADE;
      DROP VIEW IF EXISTS sivel2_sjr_ultimaatencion_aux CASCADE;
    SQL
  end
end
