# frozen_string_literal: true

class ConsactividadcasoAJos19 < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      ALTER MATERIALIZED VIEW sivel2_sjr_consactividadcaso RENAME TO
        jos19_consactividadcaso;
    SQL
  end

  def down
    execute(<<-SQL)
      ALTER MATERIALIZED VIEW sivel2_sjr_consactividadcaso RENAME TO
        jos19_consactividadcaso;
    SQL
  end
end
