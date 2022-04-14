class AgregaSinressCactividad < ActiveRecord::Migration[7.0]
  def up
    PlantillaHelper.inserta_n_columnas(1, 'T', 'AG', 5)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2200, 5, 'poblacion_sinsexo', 'T');
    SQL
    PlantillaHelper.inserta_n_columnas(1, 'AC', 'AI', 5)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2201, 5, 'poblacion_mujeres_r_g7', 'AC');
    SQL
    PlantillaHelper.inserta_n_columnas(1, 'AJ', 'AJ', 5)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2202, 5, 'poblacion_hombres_r_g7', 'AJ');
    SQL

    PlantillaHelper.inserta_n_columnas(7, 'AK', 'AK', 5)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2203, 5, 'poblacion_sinsexo_g1', 'AK');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2204, 5, 'poblacion_sinsexo_g2', 'AL');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2205, 5, 'poblacion_sinsexo_g3', 'AM');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2206, 5, 'poblacion_sinsexo_g4', 'AN');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2207, 5, 'poblacion_sinsexo_g5', 'AO');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2208, 5, 'poblacion_sinsexo_g6', 'AP');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2209, 5, 'poblacion_sinsexo_g7', 'AQ');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='2200' 
        AND id<='2209';
    SQL
    PlantillaHelper.elimina_n_columnas(7, 'AK', 'AQ', 5)
    PlantillaHelper.elimina_n_columnas(1, 'AJ', 'AJ', 5)
    PlantillaHelper.elimina_n_columnas(1, 'AC', 'AI', 5)
    PlantillaHelper.elimina_n_columnas(1, 'T', 'AH', 5)
  end
end
