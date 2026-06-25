class UnificaOrientacionsexualPersona < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      UPDATE msip_persona AS p
        SET ultimaorientacionsexual = v.orientacionsexual
        FROM sivel2_gen_victima AS v
        WHERE v.persona_id=p.id
          AND v.orientacionsexual IS NOT NULL
          AND v.orientacionsexual <> 'S'
          AND p.ultimaorientacionsexual = 'S'
    SQL
  end
  def down
    raise IrreversibleMigration
  end
end
