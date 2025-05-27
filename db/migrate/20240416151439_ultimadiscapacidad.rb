# frozen_string_literal: true

class Ultimadiscapacidad < ActiveRecord::Migration[7.1]
  def up
    add_column(:msip_persona, :ultimadiscapacidad_id, :integer, default: nil)
    execute(<<-SQL)
      UPDATE msip_persona SET ultimadiscapacidad_id=vs.discapacidad_id
        FROM sivel2_sjr_victimasjr AS vs
        JOIN sivel2_gen_victima AS v ON vs.victima_id=v.id
        WHERE v.persona_id=msip_persona.id
        AND vs.discapacidad_id IS NOT NULL;
    SQL
  end

  def down
    remove_column(:msip_persona, :ultimadiscapacidad_id)
  end
end
