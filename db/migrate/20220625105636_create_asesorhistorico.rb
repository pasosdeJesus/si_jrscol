class CreateAsesorhistorico < ActiveRecord::Migration[7.0]
  def change
    create_table :asesorhistorico do |t|
      t.integer :casosjr_id, null: false
      t.date :fechainicio, null: false
      t.date :fechafin, null: false
      t.references :usuario, null: false, foreign_key: true

      t.timestamps
    end
    add_foreign_key :asesorhistorico, :sivel2_sjr_casosjr, column: :casosjr_id, primary_key: :id_caso
  end
end
