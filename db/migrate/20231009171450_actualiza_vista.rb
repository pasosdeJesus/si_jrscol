class ActualizaVista < ActiveRecord::Migration[7.0]
  def up
    execute <<-EOF
      DROP MATERIALIZED VIEW sivel2_gen_conscaso CASCADE;
    EOF
  end
  def down
    execute <<-EOF
      DROP MATERIALIZED VIEW sivel2_gen_conscaso CASCADE;
    EOF
  end
end
