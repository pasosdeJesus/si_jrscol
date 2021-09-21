class AjustaLatlonPaisesUbicacionpre < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
      UPDATE sip_ubicacionpre SET 
        latitud=(SELECT latitud FROM sip_pais WHERE sip_pais.id=pais_id),
        longitud=(SELECT longitud FROM sip_pais WHERE sip_pais.id=pais_id)
        WHERE departamento_id IS NULL;
    SQL
  end
end
