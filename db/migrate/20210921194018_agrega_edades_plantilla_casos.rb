class AgregaEdadesPlantillaCasos < ActiveRecord::Migration[6.1]
  def agrega_campos_edad
    execute <<-SQL
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (393, 44, 'contacto_edad_fecha_recepcion', 'M');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (394, 44, 'contacto_edad_ultimaatencion', 'N');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (395, 44, 'familiar1_edad_fecha_recepcion', 'AX');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (396, 44, 'familiar1_edad_ultimaatencion', 'AY');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (397, 44, 'familiar2_edad_fecha_recepcion', 'CD');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (398, 44, 'familiar2_edad_ultimaatencion', 'CE');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (399, 44, 'familiar3_edad_fecha_recepcion', 'DJ');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (400, 44, 'familiar3_edad_ultimaatencion', 'DK');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (401, 44, 'familiar4_edad_fecha_recepcion', 'EP');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (402, 44, 'familiar4_edad_ultimaatencion', 'EQ');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (403, 44, 'familiar5_edad_fecha_recepcion', 'FV');
      INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (404, 44, 'familiar5_edad_ultimaatencion', 'FW');
    SQL
  end
  def quita_campos_edad
    execute <<-SQL
      DELETE FROM public.heb412_gen_campoplantillahcm WHERE id>='393' AND id<='404';
    SQL
  end
  def sigcol(col)
    return col.next
  end
  ## Columna siguiente n veces
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
      if col[1] && col[1] == 'A'
        c0 = col[0] == 'A' ? '' : (col[0].ord - 1)
        c1 = 'Z'
      else
        if col[1]
          c0 = col[0].ord
          c1 = col[1].ord - 1
        else
          c0 = ''
          c1 = col[0].ord - 1
        end
      end
      return c0.chr + c1.chr
  end
  def corre_resto_a_izquierda(inicial, final)
    columnas = []
    col = inicial
    while col!=final do
      columnas.push(col)
      col = sigcol(col)
    end 
    columnas.each do |co|
      execute <<-SQL
        UPDATE public.heb412_gen_campoplantillahcm SET columna='#{prevcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= 44;
      SQL
    end 
  end
  def corre_resto_a_derecha(final, inicial)
    columnas = []
    col = final
    while col!=inicial do
      columnas.push(col)
      col = prevcol(col)
    end 
    columnas.each do |co|
      execute <<-SQL
        UPDATE public.heb412_gen_campoplantillahcm SET columna='#{sigcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= 44;
      SQL
    end 
  end
  def up
    limitesder = [['LY', 'L'], ['MA', 'AW'], ['MC', 'CC'], ['ME', 'DI'], ['MG', 'EO'], ['MI', 'FU']]
    limitesder.each do |limite|
      corre_resto_a_derecha(limite[0], limite[1])
    end 
    agrega_campos_edad
  end
  def down
    quita_campos_edad
    limitesizq = [['FX', 'ML'], ['ER', 'MJ'], ['DL', 'MH'], ['CF', 'MF'], ['AZ', 'MD'], ['O', 'MB']]
    limitesizq.each do |limite|
      corre_resto_a_izquierda(limite[0], limite[1])
    end 
  end
end
