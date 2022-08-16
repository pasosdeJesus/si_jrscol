class CreaIndicesSoundexesp < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE INDEX sip_persona_soundexpm_nombres
        ON sip_persona (soundexespm(nombres));
      CREATE INDEX sip_persona_soundexpm_apellidos
        ON sip_persona (soundexespm(apellidos));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX sip_persona_soundexpm_nombres;
      DROP INDEX sip_persona_soundexpm_apellidos;
    SQL
  end
end
