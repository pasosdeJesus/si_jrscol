module PlantillaHelper

  # Inserta n columnas antes de la columna col
  # moviendo las que estaban entre la columna col y col_final
  # a col+n hasta col_final+n
  def self.inserta_n_columnas(n, col, col_final, plantilla_id)
    i = col_final
    imasn = sigcolp(col_final, n)
    loop do
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm "\
        "SET columna='#{imasn}' "\
        "WHERE columna='#{i}' AND plantillahcm_id= #{plantilla_id}"
      )
      if i == col 
        break
      end
      i = prevcol(i)
      imasn = prevcol(imasn)
    end 
  end

  # Elimina n columnas entre col y col+n-1
  # Mueve las que están en col+n y col_final a col y col_final-n
  def self.elimina_n_columnas(n, col, col_final, plantilla_id)
    #puts "OJO elimina_n_columnas(n=#{n}, col=#{col}, col_final=#{col_final}, plantilla_id=#{plantilla_id}"
    i = col
    imasn = sigcolp(col, n)
    if colmayor(imasn, col_final)
      # No hay que mover finales 
      return
    end
    loop do
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm "\
        "SET columna='#{i}' "\
        "WHERE columna='#{imasn}' AND plantillahcm_id= #{plantilla_id}"
      )
      if imasn == col_final
        break
      end
      i = sigcol(i)
      imasn = sigcol(imasn)
    end 
  end


  ## Para correr un bloque de columnas a la derecha se requeire
  ## la columna mayor y la columna menor límites del bloque
  def self.corre_columnas_a_derecha(col_mayor, col_menor, plantilla_id)
    columnas = []
    col = col_mayor
    while col!=col_menor do
      columnas.push(col)
      col = prevcol(col)
    end 
    columnas.each do |co|
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm SET columna='#{sigcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= #{plantilla_id}")
    end 
  end

  def self.corre_columnas_a_izquierda(col_menor, col_mayor, plantilla_id)
    columnas = []
    col = col_menor
    while col!=col_mayor do
      columnas.push(col)
      col = sigcol(col)
    end 
    columnas.each do |co|
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm SET columna='#{prevcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= #{plantilla_id}")
    end 
  end

  ## Columna Siguente
  def self.sigcol(col)
    return col.next
  end

  ## Columna siguiente n veces
  def self.sigcolp(col, n)
    veces = (1..n).to_a
    cr = col
    veces.each do |vv|
      cr = sigcol(cr)
    end
    return cr
  end

  # Columna previa (válida sólo hasta 2 bytes de tamaño)
  def self.prevcol(col)
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

  # Columna previa n  veces
  def self.prevcolp(col, n)
    veces = (1..n).to_a
    cr = col
    veces.each do |vv|
      cr = prevcol(cr)
    end
    return cr
  end

  # Decide si col1 es mayor que col2
  def self.colmayor(col1, col2)
    col1.length > col2.length || (col1.length == col2.length && col1 > col2)
  end

end
