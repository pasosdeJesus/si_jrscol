class PsuRapido < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm 
        SET nombremenu='Plantilla PSU Actividades -- flexibe pero lento'
        WHERE id=108;
      INSERT INTO heb412_gen_plantillahcm 
      (id, ruta, fuente, licencia, vista, nombremenu, filainicial)
      VALUES (53, 'Plantillas/PSU_actividades.xlsx', '',
      '', 'Actividad', 'Plantilla PSU Actividades -- rápido pero inflexibe y solo en XLSX', 7);
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM heb412_gen_plantillahcm WHERE id=53;
      UPDATE heb412_gen_plantillahcm 
        SET nombremenu='Plantilla PSU Actividades'
        WHERE id=108;
    SQL
  end

end
