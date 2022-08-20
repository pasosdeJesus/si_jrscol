class AmpliaObservacionesCasoEtiqueta < ActiveRecord::Migration[7.0]
  def up
    change_column :sivel2_gen_caso_etiqueta, 
      :observaciones, :string, :limit => 10000
  end
  def down
    change_column :sivel2_gen_caso_etiqueta, 
      :observaciones, :string, :limit => 5000
  end
end
