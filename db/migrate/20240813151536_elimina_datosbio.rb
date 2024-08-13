class EliminaDatosbio < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      DROP TABLE msip_datosbio;
    SQL
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
