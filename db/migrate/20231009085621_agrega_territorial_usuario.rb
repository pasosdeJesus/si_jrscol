class AgregaTerritorialUsuario < ActiveRecord::Migration[7.0]
  def up
    add_column :usuario, :territorial_id, :integer
    execute <<-SQL
      UPDATE usuario SET territorial_id=oficina_id;
    SQL
    execute <<-SQL
      UPDATE usuario SET oficina_id=NULL;
    SQL
    add_foreign_key :usuario, :territorial
  end

  def down
    execute <<-SQL
      UPDATE usuario SET oficina_id=territorial_id;
    SQL
    remove_column :usuario, :territorial_id, :integer
  end
end
