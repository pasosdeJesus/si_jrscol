class EliminaProceso < ActiveRecord::Migration[7.0]
  def up
    drop_table :derecho_procesosjr
    drop_table :procesosjr
    drop_table :accion
    drop_table :proceso
  end

  def down
    raise IrreversibleMigration
  end
end
