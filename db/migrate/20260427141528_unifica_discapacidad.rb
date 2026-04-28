class UnificaDiscapacidad < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      UPDATE msip_persona AS p
        SET ultimadiscapacidad_id=vs.discapacidad_id
        FROM sivel2_gen_victima AS v
        JOIN sivel2_sjr_victimasjr AS vs ON vs.victima_id=v.id
        WHERE v.persona_id=p.id
          AND vs.discapacidad_id IS NOT NULL
          AND vs.discapacidad_id <> 7
          AND p.ultimadiscapacidad_id = 7
    SQL
  end

  def down
    raise IrreversibleMigration
  end
end
