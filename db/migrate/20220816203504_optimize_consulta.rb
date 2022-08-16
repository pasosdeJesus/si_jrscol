class OptimizeConsulta < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL    
      -- La siguiente es version IMMUTABLE de unaccent
      CREATE OR REPLACE function unaccent_i(text)
      RETURNS text
      LANGUAGE sql
      IMMUTABLE
      AS 'SELECT unaccent($1)'
      ;

      -- Encontramos que el siguiente optimiza buscar pares
      -- que tengan el mismo soundexespm en nombres y el mismo soundexespm en
      -- apellidos
      CREATE INDEX i_sip_persona_soundexesp_nomap ON 
        sip_persona (soundexespm(nombres) collate es_co_utf_8, 
          soundexespm(apellidos) collate es_co_utf_8)
      ; 
    SQL
  end

  def down
    execute <<-SQL    
      DROP function unaccent_i;
      DROP INDEX i_sip_persona_soundexesp_nomap;
    SQL
  end

end
