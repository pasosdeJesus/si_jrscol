module PlantillaHelper

  # Mover columnas libros de calculo plantillashcm

  ## Para correr un bloque de columnas a la derecha se requeire
  ## la columna mayor y la columna menor límites del bloque
  def self.corre_columnas_a_derecha(col_mayor, col_menor, id_plantilla)
    columnas = []
    col = col_mayor
    while col!=col_menor do
      columnas.push(col)
      col = prevcol(col)
    end 
    columnas.each do |co|
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm SET columna='#{sigcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= #{id_plantilla}")
    end 
  end

  def self.corre_columnas_a_izquierda(col_menor, col_mayor, id_plantilla)
    columnas = []
    col = col_menor
    while col!=col_mayor do
      columnas.push(col)
      col = sigcol(col)
    end 
    columnas.each do |co|
      ActiveRecord::Base.connection.execute(
        "UPDATE public.heb412_gen_campoplantillahcm SET columna='#{prevcolp(co, 2)}' WHERE columna='#{co}' AND plantillahcm_id= #{id_plantilla}")
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

  # Columna previa (válida sólo hasta 2 bits de tamaño)
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
end
