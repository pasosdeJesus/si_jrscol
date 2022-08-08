class EtBenUnif < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      INSERT INTO sip_etiqueta (id, nombre, fechacreacion, created_at, updated_at) VALUES (14, 'BENEFICIARIOS UNIFICADOS', '2022-07-08', '2022-07-08', '2022-07-08');
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM sip_etiqueta WHERE id=14; 
    SQL
  end
end
