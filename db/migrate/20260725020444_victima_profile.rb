class VictimaProfile < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      UPDATE msip_persona SET ultimoperfilorgsocial_id=14 
        WHERE ultimoperfilorgsocial_id IS NULL;
    SQL
  end
  def down
  end
end
