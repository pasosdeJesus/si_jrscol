class ActivaUnicidadNumdoc < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE sip_persona ADD 
        CONSTRAINT tipoynumdoc_unicos UNIQUE (tdocumento_id, numerodocumento);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sip_persona DROP CONSTRAINT tipoynumdoc_unicos;
    SQL
  end
end
