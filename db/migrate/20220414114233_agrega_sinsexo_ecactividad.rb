class AgregaSinsexoEcactividad < ActiveRecord::Migration[7.0]
  def up
    PlantillaHelper.inserta_n_columnas(1, 'T', 'BR', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2179, 45, 'poblacion_sinsexo', 'T');
    SQL
    PlantillaHelper.inserta_n_columnas(7, 'AK', 'BS', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2180, 45, 'poblacion_sinsexo_g1', 'AK');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2181, 45, 'poblacion_sinsexo_g2', 'AL');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2182, 45, 'poblacion_sinsexo_g3', 'AM');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2183, 45, 'poblacion_sinsexo_g4', 'AN');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2184, 45, 'poblacion_sinsexo_g5', 'AO');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2185, 45, 'poblacion_sinsexo_g6', 'AP');
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2186, 45, 'poblacion_sinsexo_g7', 'AQ');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='2179' 
        AND id<='2186';
    SQL
    PlantillaHelper.elimina_n_columnas(7, 'AK', 'BZ', 45)
    PlantillaHelper.elimina_n_columnas(1, 'T', 'BS', 45)
  end
end
