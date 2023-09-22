class OptimizaConsbenefactcaso < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE INDEX i_cor1440_gen_actividadpf_proyectofinanciero_id ON
        cor1440_gen_actividadpf (proyectofinanciero_id);
    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX i_cor1440_gen_actividadpf_proyectofinanciero_id;
    SQL
  end

end
