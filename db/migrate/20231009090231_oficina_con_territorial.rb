class OficinaConTerritorial < ActiveRecord::Migration[7.0]
  def up
    add_column :msip_oficina, :territorial_id, :integer
    execute <<-SQL
      UPDATE msip_oficina SET territorial_id=id;
    SQL
  end
  def down
    remove_column :msip_oficina, :territorial_id
  end
end
