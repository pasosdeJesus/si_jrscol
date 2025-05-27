# frozen_string_literal: true

class AgregarTdocumentoPpt < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      INSERT INTO msip_tdocumento (id, nombre, sigla, formatoregex,#{" "}
        fechacreacion, fechadeshabilitacion, created_at,#{" "}
        updated_at, observaciones, ayuda) VALUES (16, 'PERMISO POR PROTECCIÓN TEMPORAL', 'PPT', '[0-9]*', '2023-12-10', NULL, NULL, NULL, NULL, 'Solo dígitos. Por ejemplo 323948');
    SQL
  end

  def down
    execute(<<-SQL)
      DELETE FROM msip_tdocumento WHERE id=16;
    SQL
  end
end
