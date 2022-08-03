class NombresApellidosMayusculas < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE sip_persona SET nombres=UPPER(nombres);
      UPDATE sip_persona SET apellidos=UPPER(apellidos);
      -- Basta esto porque nombres y apellidos en la tabla persona ya tienen locale es_CO

      UPDATE sip_persona SET nombres=regexp_replace(regexp_replace(regexp_replace(nombres, '\s\s+', ' '), '^\s', ''), '\s$', '');
      UPDATE sip_persona SET apellidos=regexp_replace(regexp_replace(regexp_replace(apellidos, '\s\s+', ' '), '^\s', ''), '\s$', '');
    SQL
  end

  def down
    raise IrreversibleMigration
  end
end
