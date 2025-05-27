# frozen_string_literal: true

class AgregaDiscSininfo < ActiveRecord::Migration[7.1]
  def up
    execute(<<-SQL)
      INSERT INTO discapacidad#{" "}
      (id, nombre, observaciones, fechacreacion, fechadeshabilitacion,
      created_at, updated_at) VALUES
      (7, 'SIN INFORMACIÓN', '', '2024-04-17', '2024-04-17',
      '2024-04-17', '2024-04-17');
      UPDATE msip_persona SET ultimadiscapacidad_id=7
        WHERE ultimadiscapacidad_id IS NULL;
      ALTER TABLE msip_persona ALTER COLUMN ultimadiscapacidad_id
        SET DEFAULT 7;
    SQL
  end

  def down
    execute(<<-SQL)
      ALTER TABLE msip_persona ALETR COLUMN ultimadiscapacidad_id
        SET DEFAULT NULL;
      UPDATE msip_persona SET ultimadiscapacidad_id=NULL
        WHERE ultimadiscapacidad_id=7;
      DELETE FROM discapacidad WHERE id=7;
    SQL
  end
end
