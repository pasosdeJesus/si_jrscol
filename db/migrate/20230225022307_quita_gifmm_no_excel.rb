# frozen_string_literal: true

class QuitaGifmmNoExcel < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      DELETE FROM heb412_gen_campoplantillahcm WHERE
        plantillahcm_id IN (
          SELECT id FROM heb412_gen_plantillahcm#{" "}
          WHERE vista='Consgifmm' AND id<>51
        )
      ;

      DELETE FROM cor1440_gen_plantillahcm_proyectofinanciero WHERE
        plantillahcm_id IN (
          SELECT id FROM heb412_gen_plantillahcm#{" "}
          WHERE vista='Consgifmm' AND id<>51
        )
      ;
      DELETE FROM heb412_gen_formulario_plantillahcm WHERE
        plantillahcm_id IN (
          SELECT id FROM heb412_gen_plantillahcm#{" "}
          WHERE vista='Consgifmm' AND id<>51
        )
      ;

      DELETE FROM heb412_gen_plantillahcm WHERE vista='Consgifmm' AND id<>51;
    SQL
  end

  def down
  end
end
