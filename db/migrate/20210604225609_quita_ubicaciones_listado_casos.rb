class QuitaUbicacionesListadoCasos < ActiveRecord::Migration[6.1]
  def elimina_campos_ubicacion
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='267' AND id<='283';
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id='219';
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='900' AND id<='908';
    SQL
  end
  def inserta_campos_ubicacion
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (267, 44, 'ubicacion1_pais', 'GE');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (268, 44, 'ubicacion1_departamento', 'GF');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (269, 44, 'ubicacion1_municipio', 'GG');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (270, 44, 'ubicacion1_clase', 'GH');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (271, 44, 'ubicacion1_longitud', 'GI');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (272, 44, 'ubicacion1_latitud', 'GJ');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (273, 44, 'ubicacion1_lugar', 'GK');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (274, 44, 'ubicacion1_sitio', 'GL');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (275, 44, 'ubicacion1_tsitio', 'GM');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (219, 44, 'ubicacion2_pais', 'GN');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (276, 44, 'ubicacion2_departamento', 'GO');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (277, 44, 'ubicacion2_municipio', 'GP');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (278, 44, 'ubicacion2_clase', 'GQ');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (279, 44, 'ubicacion2_longitud', 'GR');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (280, 44, 'ubicacion2_latitud', 'GS');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (281, 44, 'ubicacion2_lugar', 'GT');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (282, 44, 'ubicacion2_sitio', 'GU');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (283, 44, 'ubicacion2_tsitio', 'GV');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (900, 44, 'ubicacion3_pais', 'GW');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (901, 44, 'ubicacion3_departamento', 'GX');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (902, 44, 'ubicacion3_municipio', 'GY');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (903, 44, 'ubicacion3_clase', 'GZ');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (904, 44, 'ubicacion3_longitud', 'HA');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (905, 44, 'ubicacion3_latitud', 'HB');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (906, 44, 'ubicacion3_lugar', 'HC');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (907, 44, 'ubicacion3_sitio', 'HD');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (908, 44, 'ubicacion3_tsitio', 'HE');
    SQL
  end
  def sigcol(col)
    if col[1] == 'Z'
      c0 = col[0].ord + 1
      c1 =  'A'
    else
      c0 = col[0].ord
      c1 = col[1].ord + 1
    end
    return c0.chr + c1.chr
  end
  def sigcolp(col, n)
    veces = (1..n).to_a
    cr = col
    veces.each do |vv|
      cr = sigcol(cr)
    end
    return cr
  end
  # Columna previa n  veces
  def prevcolp(col, n)
    veces = (1..n).to_a
    cr = col
    veces.each do |vv|
      cr = prevcol(cr)
    end
    return cr
  end
  def prevcol(col)
      if col[1] == 'A'
        c0 = col[0].ord - 1
        c1 =  'Z'
      else
        c0 = col[0].ord
        c1 = col[1].ord - 1
      end
      return c0.chr + c1.chr
  end
  def corre_resto_a_izquierda
    columnas = []
    col = 'HF'
    while col!='NA' do
      columnas.push(col)
      col = sigcol(col)
    end 
    columnas.each do |col|
      execute <<-SQL
        UPDATE public.heb412_gen_campoplantillahcm SET columna='#{prevcolp(col, 27)}' WHERE columna='#{col}';
      SQL
    end 
  end
  def corre_resto_a_derecha
    columnas = []
    col = 'HF'
    while col!='LZ' do
      columnas.push(col)
      col = sigcol(col)
    end 
    columnas.each do |col|
      execute <<-SQL
        UPDATE public.heb412_gen_campoplantillahcm SET columna='#{sigcolp(col, 27)}' WHERE columna='#{col}';
      SQL
    end 
  end
  def up
    elimina_campos_ubicacion
    corre_resto_a_izquierda
  end
  def down
    corre_resto_a_derecha
    inserta_campos_ubicacion
  end
end
