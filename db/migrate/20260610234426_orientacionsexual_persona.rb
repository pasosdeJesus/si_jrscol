class OrientacionsexualPersona < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE msip_persona ADD COLUMN
        ultimaorientacionsexual CHARACTER(1) NOT NULL DEFAULT 'S';
      ALTER TABLE msip_persona ADD CONSTRAINT
        "ultimaorientacionsexual_check" CHECK 
        (ultimaorientacionsexual = 'L' OR
        ultimaorientacionsexual = 'G' OR
        ultimaorientacionsexual = 'B' OR
        ultimaorientacionsexual = 'T' OR
        ultimaorientacionsexual = 'Q' OR
        ultimaorientacionsexual = 'H' OR
        ultimaorientacionsexual = 'S' OR
        ultimaorientacionsexual = 'I' OR
        ultimaorientacionsexual = 'O');
    SQL
  end
  def down
    execute <<-SQL
      ALTER TABLE msip_persona DROP CONSTRAINT "ultimaorientacionsexual_check";
      ALTER TABLE msip_persona DROP COLUMN ultimaorientacionsexual;
    SQL
  end
end
