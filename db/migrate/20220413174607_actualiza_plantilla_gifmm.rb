class ActualizaPlantillaGifmm < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm 
        SET ruta='Plantillas/GIFMM-v1.1.ods', 
        nombremenu='GIFMM-v1.1' 
        WHERE id=43;
    SQL
  end
  def down
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm 
        SET ruta='Plantillas/GIFMM-v1.ods', 
        nombremenu='GIFMM-v1' 
        WHERE id=43;
    SQL
  end
end
