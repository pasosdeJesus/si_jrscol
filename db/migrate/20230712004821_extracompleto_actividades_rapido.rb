# frozen_string_literal: true

class ExtracompletoActividadesRapido < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      UPDATE heb412_gen_plantillahcm#{" "}
        SET nombremenu='Listado extracompleto de actividades -- flexibe pero lento'
        WHERE id=45;
      INSERT INTO heb412_gen_plantillahcm#{" "}
      (id, ruta, fuente, licencia, vista, nombremenu, filainicial)
      VALUES (54, 'Plantillas/listado_extracompleto_de_actividades.xlsx', '',
      '', 'Actividad', 'Listado extracompleto de actividades -- rápido pero inflexibe y solo en XLSX', 7);
    SQL
  end

  def down
    execute(<<-SQL)
      DELETE FROM heb412_gen_plantillahcm WHERE id=54;
      UPDATE heb412_gen_plantillahcm#{" "}
        SET nombremenu='Listado extracompleto de Actividades'
        WHERE id=45;
    SQL
  end
end
