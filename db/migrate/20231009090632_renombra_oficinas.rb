class RenombraOficinas < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE msip_oficina SET territorial_id=id;
      UPDATE msip_oficina SET nombre='Soacha' WHERE id=6;
      UPDATE msip_oficina SET nombre='Barrancabermeja' WHERE id=3;
      UPDATE msip_oficina SET nombre='Cúcuta' WHERE id=4;
      UPDATE msip_oficina SET nombre='Bogotá' WHERE id=7;
      UPDATE msip_oficina SET nombre='Pasto' WHERE id=5;
      UPDATE msip_oficina SET nombre='Buenaventura' WHERE id=2;
      UPDATE msip_oficina SET nombre='Sin Información' WHERE id=1;
      UPDATE msip_oficina SET nombre='Pereira' WHERE id=101;
      UPDATE msip_oficina SET nombre='Cartagena' WHERE id=102;

      INSERT INTO territorial (id, nombre, fechacreacion, 
        fechadeshabilitacion, created_at, updated_at, observaciones, 
        pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (8, 'SANTANDER', '2023-10-09', 
        NULL, '2023-10-09', '2023-10-09', '', 
        170, 43, 27, NULL);

      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at, 
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (8, 'Bucaramanga', 8,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09', 
        '', 170, 43, 27, 9867);
      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at, 
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (9, 'Ibague', 6,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09', 
        '', 170, 46, 34, 11103);
      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at, 
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (10, 'Santa Rosa del Sur', 3,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09', 
        '', 170, 7, 1138, 788);
      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at,
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (11, 'Tibú', 4,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09',
        '', 170, 39, 1320, 9427);
      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at, 
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (12, 'Ipiales', 5,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09', 
        '', 170, 38, 611, 8302);
      INSERT INTO msip_oficina (id, nombre, territorial_id, 
        fechacreacion, fechadeshabilitacion, created_at, updated_at, 
        observaciones, pais_id, departamento_id, municipio_id, clase_id) 
        VALUES (13, 'Palmira', 2,
        '2023-10-09', NULL, '2023-10-09', '2023-10-09', 
        '', 170, 47, 881, 12171);
    SQL
  end
  def down
    change_column :usuario, :territorial_id, :integer, null: true
    execute <<-SQL
      DELETE FROM msip_oficina WHERE id>=8 AND id<=13;
    SQL
    execute <<-SQL
      DELETE FROM territorial WHERE id=8;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='SOACHA' WHERE id=6;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='MAGDALENA MEDIO' WHERE id=3;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='CÚCUTA' WHERE id=4;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='NACIONAL' WHERE id=7;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='NARIÑO' WHERE id=5;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='VALLE' WHERE id=2;
    SQL
    execute <<-SQL
      UPDATE msip_oficina SET nombre='SIN INFORMACIÓN' WHERE id=1;
    SQL
  end
end
