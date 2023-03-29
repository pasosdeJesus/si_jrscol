class ConvsexoMho < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='H' WHERE sexo='M'; 
      UPDATE msip_persona SET sexo='M' WHERE sexo='F';
      UPDATE msip_persona SET sexo='O' WHERE sexo='S';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('MHO' LIKE '%' || sexo || '%');
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='F' WHERE sexo='M'; 
      UPDATE msip_persona SET sexo='M' WHERE sexo='H';
      UPDATE msip_persona SET sexo='S' WHERE sexo='O';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('FMS' LIKE '%' || sexo || '%');
    SQL
  end
end
