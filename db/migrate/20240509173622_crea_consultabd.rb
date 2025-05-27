# frozen_string_literal: true

class CreaConsultabd < ActiveRecord::Migration[7.1]
  def up
    execute(<<-SQL)
      CREATE MATERIALIZED VIEW consultabd AS
        SELECT row_number() over () AS numfila, *#{" "}
          FROM (SELECT 1 as valor) AS s;
    SQL
  end

  def down
    execute(<<-SQL)
      DROP MATERIALIZED VIEW consultabd;
    SQL
  end
end
