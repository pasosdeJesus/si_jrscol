class AgregaCasosasociadosEcactividades < ActiveRecord::Migration[7.0]

  def up
    PlantillaHelper.inserta_n_columnas(1, 'BW', 'CA', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2187, 45, 'casos_asociados', 'BW');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id='2187';
    SQL
    PlantillaHelper.elimina_n_columnas(1, 'BW', 'CB', 45)
  end
end
