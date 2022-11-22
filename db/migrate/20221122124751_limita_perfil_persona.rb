class LimitaPerfilPersona < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
    UPDATE sip_perfilorgsocial 
      SET fechadeshabilitacion='2022-11-22' 
      WHERE id IN (1, 2, 3, 4, 5);
    UPDATE sip_perfilorgsocial
      SET nombre='MIGRANTE CON VOCACIÓN DE PERMANENCIA' 
      WHERE id=10;
    UPDATE sip_perfilorgsocial
      SET nombre='MIGRANTE EN TRÁNSITO'
      WHERE id=11;
    UPDATE sip_perfilorgsocial
      SET nombre='MIGRANTE PENDULAR' 
      WHERE id=12;
    INSERT INTO sip_perfilorgsocial 
      (id, nombre, fechacreacion, created_at, updated_at) VALUES 
      (14, 'VÍCTIMA', '2022-11-22', NOW(), NOW());
    INSERT INTO sip_perfilorgsocial 
      (id, nombre, fechacreacion, created_at, updated_at) VALUES 
      (15, 'VÍCTIMA DE DOBLE AFECTACIÓN', '2022-11-22', NOW(), NOW());
    INSERT INTO sip_perfilorgsocial 
      (id, nombre, fechacreacion, created_at, updated_at) VALUES 
      (16, 'COLOMBIANO RETORNADO', '2022-11-22', NOW(), NOW());
    SQL
  end
  def down
    execute <<-SQL
    DELETE FROM sip_perfilorgsocial WHERE id IN (14,15,16);
    UPDATE sip_perfilorgsocial
      SET nombre='PENDULAR' 
      WHERE id=12;
    UPDATE sip_perfilorgsocial
      SET nombre='EN TRÁNSITO'
      WHERE id=11;
    UPDATE sip_perfilorgsocial
      SET nombre='CON VOCACIÓN DE PERMANENCIA' 
      WHERE id=10;
    UPDATE sip_perfilorgsocial 
      SET fechadeshabilitacion=NULL
      WHERE id IN (1, 2, 3, 4, 5);
    SQL
  end

end
