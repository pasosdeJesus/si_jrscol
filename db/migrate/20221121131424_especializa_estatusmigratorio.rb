class EspecializaEstatusmigratorio < ActiveRecord::Migration[7.0]
  def up
    add_column :sivel2_sjr_statusmigratorio, :formupersona, :bool
    execute <<-SQL
    UPDATE sivel2_sjr_statusmigratorio SET formupersona='t' 
      WHERE id in (1, 7, 8);
    SQL
  end
  def down
    remove_column :sivel2_sjr_statusmigratorio, :formupersona, :bool
  end
end
