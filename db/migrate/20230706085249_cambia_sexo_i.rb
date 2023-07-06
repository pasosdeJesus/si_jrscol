class CambiaSexoI < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='I' WHERE sexo='O';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('MHSI' LIKE '%' || sexo || '%');
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE msip_persona DROP CONSTRAINT IF EXISTS persona_sexo_check;
      UPDATE msip_persona SET sexo='O' WHERE sexo='I';
      ALTER TABLE msip_persona ADD CONSTRAINT persona_sexo_check
        CHECK ('MHSO' LIKE '%' || sexo || '%');
    SQL
  end
end
