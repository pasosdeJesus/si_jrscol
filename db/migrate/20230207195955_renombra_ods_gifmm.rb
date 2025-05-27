# frozen_string_literal: true

class RenombraOdsGifmm < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      UPDATE heb412_gen_plantillahcm SET ruta='Plantillas/GIFMM-v2.ods'#{" "}
      WHERE id=51;
    SQL
  end

  def down
    execute(<<-SQL)
      UPDATE heb412_gen_plantillahcm SET ruta='Plantillas/GIFMM-v1.1.ods'#{" "}
      WHERE id=51;
    SQL
  end
end
