class SinAnexoDesplazamiento < ActiveRecord::Migration[7.1]
  def up
    drop_table :sivel2_sjr_anexo_desplazamiento
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
