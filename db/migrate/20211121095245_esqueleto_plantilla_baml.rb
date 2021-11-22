class EsqueletoPlantillaBaml < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      INSERT INTO public.heb412_gen_plantillahcm (id, ruta, fuente, 
        licencia, vista, nombremenu, filainicial) 
        VALUES (50, 'Plantillas/beneficiarios_por_aml.ods', 'pdJ', 
        'Dominio Publico', 'Benefactividadpf', 
        'Beneficiarios por Actividad de Marco Lógico (Excel)', 7);

      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, 
        nombrecampo, columna) VALUES (750, 50, 'persona_nombre', 'B');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, 
        nombrecampo, columna) VALUES (751, 50, 'persona_identificacion', 'C');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, 
        nombrecampo, columna) VALUES (752, 50, 'persona_sexo', 'D');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, 
        nombrecampo, columna) VALUES (753, 50, 'edad_en_actividad', 'E');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, 
        nombrecampo, columna) VALUES (754, 50, 'rangoedadac_nombre', 'F');

    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>=750 AND id<=754;
      DELETE FROM public.heb412_gen_plantillahcm WHERE id=50;
    SQL
  end
end
