# frozen_string_literal: true

class CompAcRapido < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      UPDATE heb412_gen_plantillahcm#{" "}
        SET nombremenu='Listado Completo de Actividades -- flexibe pero lento'
        WHERE id=5;
      INSERT INTO heb412_gen_plantillahcm#{" "}
      (id, ruta, fuente, licencia, vista, nombremenu, filainicial)
      VALUES (52, 'Plantillas/listado_de_actividades3.xlsx', 'Pasos de Jesús',
      'Dominio Público', 'Actividad', 'Listado Completo de Actividades -- rápido pero inflexibe y solo en XLSX', 7);
    SQL
  end

  def down
    execute(<<-SQL)
      DELETE FROM heb412_gen_plantillahcm WHERE id=52;
      UPDATE heb412_gen_plantillahcm#{" "}
        SET nombremenu='Listado Completo de Actividades'
        WHERE id=5;
    SQL
  end
end
