class CreateProductoleg < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper
  def up
    create_table :productoleg do |t|
      t.string :nombre, limit: 500, null: false, collation: 'es_co_utf_8'
      t.string :observaciones, limit: 5000
      t.date :fechacreacion, null: false
      t.date :fechadeshabilitacion

      t.timestamps
    end
    cambiaCotejacion('productoleg', 'nombre', 500, 'es_co_utf_8')
    execute <<-SQL
      INSERT INTO productoleg (id, nombre, fechacreacion, 
        created_at, updated_at) VALUES (
        1, 'ALIMENTOS', '2023-07-19', '2023-07-19', '2023-07-19');
      INSERT INTO productoleg (id, nombre, fechacreacion, 
        created_at, updated_at) VALUES (
        2, 'HOSPEDAJE', '2023-07-19', '2023-07-19', '2023-07-19');
      INSERT INTO productoleg (id, nombre, fechacreacion, 
        created_at, updated_at) VALUES (
        3, 'MATERIALES', '2023-07-19', '2023-07-19', '2023-07-19');
      INSERT INTO productoleg (id, nombre, fechacreacion, 
        created_at, updated_at) VALUES (
        4, 'VIAJE', '2023-07-19', '2023-07-19', '2023-07-19');
      SELECT setval('productoleg_id_seq', 100);
    SQL
  end
  def down
    drop_table :productoleg
  end
end
