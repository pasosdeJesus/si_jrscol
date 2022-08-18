class CambiaUnaccentI < ActiveRecord::Migration[7.0]
  def change
    # No es necesario unaccent_i porque ya existe f_unaccent
    execute <<-SQL    
      DROP function unaccent_i CASCADE;
    SQL
  end

  def down
    execute <<-SQL    
      CREATE OR REPLACE function unaccent_i(text)
      RETURNS text
      LANGUAGE sql
      IMMUTABLE
      AS 'SELECT unaccent($1)'
      ;
    SQL
  end

end
