# frozen_string_literal: true

class DiscapacidadObligatoria < ActiveRecord::Migration[7.1]
  def up
    execute(<<-SQL)
      ALTER TABLE msip_persona ALTER COLUMN ultimadiscapacidad_id SET NOT NULL;
    SQL
  end

  def down
    execute(<<-SQL)
      ALTER TABLE msip_persona ALTER COLUMN ultimadiscapacidad_id DROP NOT NULL;
    SQL
  end
end
