class AgregaOtroExtracompletoac < ActiveRecord::Migration[7.0]

  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2195, 'AR', 'poblacion_intersexuales_g7'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2194, 'AR', 'poblacion_intersexuales_g6'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2193, 'AR', 'poblacion_intersexuales_g5'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2192, 'AR', 'poblacion_intersexuales_g4'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2191, 'AR', 'poblacion_intersexuales_g3'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2190, 'AR', 'poblacion_intersexuales_g2'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2189, 'AR', 'poblacion_intersexuales_g1'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      45, 2188, 'U', 'poblacion_intersexuales'
    )

  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2188)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2189)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2190)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2191)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2192)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2193)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2194)
    Heb412Gen::PlantillaHelper.elimina_columna(45, 2195)
  end

end
