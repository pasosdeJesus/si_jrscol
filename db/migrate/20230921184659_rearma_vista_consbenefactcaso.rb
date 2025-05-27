# frozen_string_literal: true

class RearmaVistaConsbenefactcaso < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso;
    SQL
  end

  def down
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso;
    SQL
  end
end
