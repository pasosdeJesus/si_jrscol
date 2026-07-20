class Rehacerbenefactividadpf < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS cor1440_gen_benefext CASCADE;
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso;
      DROP VIEW IF EXISTS cor1440_gen_benefext CASCADE;
    SQL
  end
end
