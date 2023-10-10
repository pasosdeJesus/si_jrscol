class CreateTerritorial < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper
  def up
    create_table :territorial do |t|
      t.string :nombre, limit: 500, null: false
      t.string :observaciones, limit: 5000
      t.date :fechacreacion, null: false
      t.date :fechadeshabilitacion
      t.integer :pais_id
      t.integer :departamento_id
      t.integer :municipio_id
      t.integer :clase_id

      t.timestamps
    end
    cambiaCotejacion('territorial', 'nombre', 500, 'es_co_utf_8')
    add_foreign_key :territorial, :msip_pais, column: :pais_id
    add_foreign_key :territorial, :msip_departamento, column: :departamento_id
    add_foreign_key :territorial, :msip_municipio, column: :municipio_id
    add_foreign_key :territorial, :msip_clase, column: :clase_id
    execute <<-SQL
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (1, 'SIN INFORMACIÓN', '2013-05-13', NULL, '2013-05-13', '2013-05-13', NULL, NULL, NULL, NULL, NULL);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (2, 'VALLE DEL CAUCA', '2013-05-13', NULL, '2013-05-13', '2018-06-20 22:09:05.965897', '', NULL, NULL, NULL, NULL);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (3, 'MAGDALENA MEDIO', '2013-05-13', NULL, '2013-05-13', '2013-05-13', NULL, 170, 43, 1319, 9899);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (4, 'NORTE DE SANTANDER', '2013-05-13', NULL, '2013-05-13', '2016-05-13 21:36:35.029649', '', 170, 39, 32, 9041);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (5, 'NARIÑO', '2013-05-13', NULL, '2013-05-13', '2013-05-13', NULL, 170, 38, 44, 7907);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (7, 'NACIONAL', '2013-07-05', NULL, '2013-05-13', '2015-05-14 12:39:19.66094', NULL, 170, 4, 24, 238);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (6, 'SOACHA', '2013-05-13', NULL, '2013-05-13', '2021-10-15 22:32:01.085637', '', 170, 27, 1216, 4758);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (101, 'EJE CAFETERO', '2023-03-17', NULL, '2023-03-17 17:31:33.722675', '2023-03-17 17:31:33.722675', '', 170, 42, 45, NULL);
      INSERT INTO public.territorial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, clase_id) VALUES (102, 'CARIBE', '2023-03-17', NULL, '2023-03-17 17:32:04.066646', '2023-03-17 17:32:04.066646', '', 170, 7, 31, NULL);
    SQL
  end
  def down
    drop_table :territorial
  end
end
