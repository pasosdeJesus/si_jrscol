# frozen_string_literal: true

class PreparaMasAntesSigla < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      DROP VIEW IF EXISTS cor1440_gen_benefext2 CASCADE;
      DROP VIEW IF EXISTS rep2 CASCADE;
      DROP VIEW IF EXISTS xy CASCADE;
    SQL
  end

  def down
    execute(<<-SQL)
      DROP VIEW IF EXISTS xy CASCADE;
      DROP VIEW IF EXISTS rep2 CASCADE;
      DROP VIEW IF EXISTS cor1440_gen_benefext2 CASCADE;
    SQL
  end
end
