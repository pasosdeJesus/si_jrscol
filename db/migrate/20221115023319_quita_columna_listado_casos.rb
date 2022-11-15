class QuitaColumnaListadoCasos < ActiveRecord::Migration[7.0]

  def up
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id='2172';
    SQL
    PlantillaHelper.elimina_n_columnas(1, 'BV', 'CA', 45)
  end

  def down
    PlantillaHelper.inserta_n_columnas(1, 'BV', 'BZ', 45)
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm 
        (id, plantillahcm_id, nombrecampo, columna) 
        VALUES (2172, 45, 'listado_casos_ids', 'BV');
    SQL
  end

end
