class RegeneraBenefactividadSinaccaso < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS cor1440_gen_benefactividadpf;
      DROP VIEW IF EXISTS cor1440_gen_benefext2;
      DROP VIEW IF EXISTS cor1440_gen_benefext;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS cor1440_gen_benefactividadpf;
      DROP VIEW IF EXISTS cor1440_gen_benefext2;
      DROP VIEW IF EXISTS cor1440_gen_benefext;
    SQL
  end
end
