# frozen_string_literal: true

class ActualizaDiscapacidadDeAsistencia < ActiveRecord::Migration[7.1]
  def up
    execute(<<-SQL)
      INSERT INTO discapacidad
      (id, nombre, observaciones, fechacreacion, fechadeshabilitacion,
      created_at, updated_at) VALUES
      (8, 'ALGUNA NO ESPECIFICADA', '', '2024-04-18', '2024-04-18',
      '2024-04-18', '2024-04-18');
      UPDATE msip_persona
        SET ultimadiscapacidad_id=6
        WHERE ultimadiscapacidad_id IS NULL
        AND id IN (SELECT persona_id
          FROM cor1440_gen_asistencia WHERE discapacidad='f');
      UPDATE msip_persona
        SET ultimadiscapacidad_id=8
        WHERE ((ultimadiscapacidad_id IS NULL) OR
          ultimadiscapacidad_id IN (6,7))
        AND id IN (SELECT persona_id
          FROM cor1440_gen_asistencia WHERE discapacidad='t');
    SQL
  end

  def down
    puts "Es mas compleo deshacer personas con discapacidad NINGUNA provenientes de listasdos de asistencia"
    execute(<<-SQL)
      UPDATE msip_persona SET ultimadiscapacidad_id=7
        WHERE ultimadiscapacidad_id=8;
      DELETE FROM discapacidad WHERE id=8;
    SQL
  end
end
