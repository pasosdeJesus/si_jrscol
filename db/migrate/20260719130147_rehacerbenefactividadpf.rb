class Rehacerbenefactividadpf < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS cor1440_gen_benefext CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW IF EXISTS cor1440_gen_benefext CASCADE;
    SQL
  end
end
