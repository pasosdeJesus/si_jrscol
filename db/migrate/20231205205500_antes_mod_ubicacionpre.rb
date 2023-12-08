class AntesModUbicacionpre < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS emblematica1 CASCADE;
      DROP VIEW IF EXISTS cmunex CASCADE;
      DROP VIEW IF EXISTS cmunrec CASCADE;
    SQL
  end
  def down
  end
end
