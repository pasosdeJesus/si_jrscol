class RearmaVistaConsbenefactcaso < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW consbenefactcaso;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW consbenefactcaso;
    SQL
  end

end
