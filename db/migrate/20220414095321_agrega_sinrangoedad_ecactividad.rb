class AgregaSinrangoedadEcactividad < ActiveRecord::Migration[7.0]
  def up
    PlantillaHelper.inserta_n_columnas(1, 'AB', 'BP', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2177, 45, 'poblacion_mujeres_r_g7', 'AB');
    SQL
    PlantillaHelper.inserta_n_columnas(1, 'AI', 'BQ', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2178, 45, 'poblacion_hombres_r_g7', 'AI');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='2177' 
        AND id<='2178';
    SQL
    PlantillaHelper.elimina_n_columnas(1, 'AI', 'BR', 45)
    PlantillaHelper.elimina_n_columnas(1, 'AB', 'BQ', 45)
  end
end
