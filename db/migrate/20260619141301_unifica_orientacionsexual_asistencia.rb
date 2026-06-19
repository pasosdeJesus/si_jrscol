class UnificaOrientacionsexualAsistencia < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      UPDATE cor1440_gen_asistencia AS a
        SET orientacionsexual = p.ultimaorientacionsexual
        FROM msip_persona AS p
        WHERE a.persona_id=p.id
          AND p.ultimaorientacionsexual IS NOT NULL
          AND p.ultimaorientacionsexual <> 'S'
          AND a.orientacionsexual = 'S'
    SQL
  end
  def down
    raise IrreversibleMigration
  end
end
