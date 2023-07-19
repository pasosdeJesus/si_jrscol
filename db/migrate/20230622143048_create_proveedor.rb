class CreateProveedor < ActiveRecord::Migration[7.0]
  def change
    create_table :proveedor do |t|
      t.string :nombre, limit: 500
      t.string :observaciones, limit: 5000
      t.date :fechacreacion
      t.date :fechadeshabilitacion

      t.timestamps
    end
  end
end
