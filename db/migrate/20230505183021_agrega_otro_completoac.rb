class AgregaOtroCompletoac < ActiveRecord::Migration[7.0]

  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 523, 'AR', 'poblacion_intersexuales_g7'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 522, 'AR', 'poblacion_intersexuales_g6'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 521, 'AR', 'poblacion_intersexuales_g5'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 520, 'AR', 'poblacion_intersexuales_g4'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 519, 'AR', 'poblacion_intersexuales_g3'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 518, 'AR', 'poblacion_intersexuales_g2'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 517, 'AR', 'poblacion_intersexuales_g1'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      5, 524, 'U', 'poblacion_intersexuales'
    )

  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(5, 524)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 517)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 518)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 519)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 520)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 521)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 522)
    Heb412Gen::PlantillaHelper.elimina_columna(5, 523)
  end

end
