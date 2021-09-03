class CambiaRangoedadSinrango < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_consexpcaso;
    SQL
    Sivel2Gen::Rangoedad.update_all 'nombre=rango' 
    remove_column :sivel2_gen_rangoedad, :rango
  end
end
