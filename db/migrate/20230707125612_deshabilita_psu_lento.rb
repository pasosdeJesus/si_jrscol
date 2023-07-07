class DeshabilitaPsuLento < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DELETE FROM heb412_gen_campoplantillahcm WHERE plantillahcm_id=108;
      DELETE FROM heb412_gen_plantillahcm WHERE id=108;
      UPDATE heb412_gen_plantillahcm
        SET nombremenu='Plantilla PSU Actividades (sólo XLSX)'
        WHERE id=53;
    SQL
  end
  def down
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm
        SET nombremenu='Plantilla PSU Actividades -- rápido pero inflexibe y solo en XLSX'
        WHERE id=53;
      INSERT INTO heb412_gen_plantillahcm
      (id, ruta, fuente, licencia, vista, nombremenu, filainicial)
      VALUES (108, 'Plantillas/PSU_actividades.ods', '',
      '', 'Actividad', 'Plantilla PSU Actividades -- flexible pero lento', 4);
    SQL
  end

end
