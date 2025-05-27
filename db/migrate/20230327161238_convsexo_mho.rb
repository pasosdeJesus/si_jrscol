# frozen_string_literal: true

class ConvsexoMho < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
       -- Deshabilita triggers
      SET session_replication_role = replica;
      -- Elimina datos incosistentes
      DELETE FROM  cor1440_gen_asistencia WHERE actividad_id#{" "}
        NOT IN (SELECT id FROM cor1440_gen_actividad);
      -- Vuelve a habilitar triggers
      SET session_replication_role = DEFAULT;

      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='H' WHERE sexo='M';#{" "}
      UPDATE msip_persona SET sexo='M' WHERE sexo='F';
      UPDATE msip_persona SET sexo='O' WHERE sexo='S';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('MHO' LIKE '%' || sexo || '%');
    SQL
  end

  def down
    execute(<<-SQL)
      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='F' WHERE sexo='M';#{" "}
      UPDATE msip_persona SET sexo='M' WHERE sexo='H';
      UPDATE msip_persona SET sexo='S' WHERE sexo='O';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('FMS' LIKE '%' || sexo || '%');
    SQL
  end
end
