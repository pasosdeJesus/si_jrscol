class AgregaPresupuestoAml < ActiveRecord::Migration[7.0]
  def change
    add_column :cor1440_gen_actividadpf, :presupuesto, :decimal, 
      null: false, default:0 
  end
end
