class AgregaOtroConsactividadcaso < ActiveRecord::Migration[7.0]

  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1106, 'AH', 'poblacion_intersexuales_g7'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1105, 'AH', 'poblacion_intersexuales_g6'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1104, 'AH', 'poblacion_intersexuales_g5'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1103, 'AH', 'poblacion_intersexuales_g4'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1102, 'AH', 'poblacion_intersexuales_g3'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1101, 'AH', 'poblacion_intersexuales_g2'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      103, 1100, 'AH', 'poblacion_intersexuales_g1'
    )

  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1100)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1101)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1102)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1103)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1104)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1105)
    Heb412Gen::PlantillaHelper.elimina_columna(103, 1106)
  end

end
