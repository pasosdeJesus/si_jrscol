class TelefonoEnPersona < ActiveRecord::Migration[7.2]
  def up
    add_column :msip_persona, :telefono, :string, limit: 127
    add_column :cor1440_gen_asistencia, :telefono, :string, limit: 127
    execute <<-SQL
      UPDATE msip_persona SET telefono=c.telefono FROM sivel2_sjr_casosjr AS c
        WHERE c.contacto_id=msip_persona.id AND 
        c.telefono IS NOT NULL AND
        TRIM(c.telefono)<>'' ;
    SQL
  end
  def down
    remove_column :msip_persona, :telefono, :string
    remove_column :cor1440_gen_asistencia, :telefono, :string
  end
end
