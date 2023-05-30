class CreateGastoaprobado < ActiveRecord::Migration[7.0]
  def change
    create_table :cor1440_gen_gastoaprobado do |t|
      t.integer :actividad_id, null: false
      t.integer :actividadpf_id, null: false
      t.decimal :valor, null: false

      t.timestamps
    end
    add_foreign_key :cor1440_gen_gastoaprobado,  :cor1440_gen_actividad,
      column: :actividad_id
    add_foreign_key :cor1440_gen_gastoaprobado,  :cor1440_gen_actividadpf,
      column: :actividadpf_id
  end
end
