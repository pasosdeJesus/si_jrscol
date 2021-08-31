class AjustaEstrategico1Seg < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      UPDATE cor1440_gen_actividadpf
        SET descripcion ='',
        resultadopf_id=89
        WHERE id=70; --ATENCIÓN PSICOSOCIAL
      INSERT INTO cor1440_gen_actividadpf
        (id, proyectofinanciero_id, nombrecorto, titulo, 
        descripcion, resultadopf_id)
        VALUES (45, 10, 'CAPSEM', 'ENTREGA DE CAPITAL SEMILLA', 
        '', 90); -- Resultado 3
      UPDATE cor1440_gen_actividadpf
        SET titulo='ORGANIZACIÓN DE ACTIVIDAD DE FORMACIÓN/CAPACITACÍON',
        resultadopf_id=90
        WHERE id=51;
      UPDATE cor1440_gen_actividadpf
        SET resultadopf_id=90
        WHERE id=156; -- ASISTENCIA/SEGUIMIENTO TÉCNICO A INICIATIVA PRODUCTIVA
    SQL
  end
  def down
    execute <<-SQL
      UPDATE cor1440_gen_actividadpf
        SET resultadopf_id=15
        WHERE id=156; -- ASISTENCIA/SEGUIMIENTO TÉCNICO A INICIATIVA PRODUCTIVA
      UPDATE cor1440_gen_actividadpf
        SET titulo='ORGANIZACIÓN DE ACTIVIDAD DE FORMACIÓN',
        resultadopf_id=15
        WHERE id=51;
      DELETE FROM cor1440_gen_actividadpf WHERE id=45;
      UPDATE cor1440_gen_actividadpf
        SET descripcion ='Deshabilitada',
        resultadopf_id=15
        WHERE id=70; 
    SQL
  end
end
