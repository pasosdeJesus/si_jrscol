class OrientacionsexualAsistencia < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE cor1440_gen_asistencia ADD COLUMN
        orientacionsexual CHARACTER(1) NOT NULL DEFAULT 'S';
      ALTER TABLE cor1440_gen_asistencia ADD CONSTRAINT
        "orientacionsexual_check" CHECK 
        (orientacionsexual = 'L' OR
        orientacionsexual = 'G' OR
        orientacionsexual = 'B' OR
        orientacionsexual = 'T' OR
        orientacionsexual = 'Q' OR
        orientacionsexual = 'H' OR
        orientacionsexual = 'S' OR
        orientacionsexual = 'I' OR
        orientacionsexual = 'O');
    SQL
  end
  def down
    execute <<-SQL
      ALTER TABLE cor1440_gen_asistencia 
        DROP CONSTRAINT "orientacionsexual_check";
      ALTER TABLE cor1440_gen_asistencia DROP COLUMN orientacionsexual;
    SQL
  end
end
