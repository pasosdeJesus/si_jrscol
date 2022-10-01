class Elimbenefext < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW benefext CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW benefext CASCADE;
    SQL
  end

end
