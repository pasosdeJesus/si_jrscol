class EsqueletoPlantillaGifmm < ActiveRecord::Migration[7.0]

  def up
    execute <<-SQL
      INSERT INTO public.heb412_gen_plantillahcm (id, ruta, fuente, 
        licencia, vista, nombremenu, filainicial) 
        VALUES (51, 'Plantillas/reporte_gifmm.ods', 'pdJ', 
        'Dominio Publico', 'Consgifmm', 
        'Reporte GIFMM (Excel)', 7);
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_plantillahcm WHERE id=51;
    SQL
  end
end
