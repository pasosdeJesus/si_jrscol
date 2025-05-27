# frozen_string_literal: true

class RegeneraConsactividad < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS sivel2_sjr_consactividadcaso;
    SQL
  end

  def down
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS sivel2_sjr_consactividadcaso;
    SQL
  end
end
