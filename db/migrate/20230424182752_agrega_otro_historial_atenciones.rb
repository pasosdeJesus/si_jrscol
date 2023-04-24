class AgregaOtroHistorialAtenciones < ActiveRecord::Migration[7.0]

  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3057, 'AJ', 'beneficiarios_os_se_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3056, 'AJ', 'beneficiarios_os_60m_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3055, 'AJ', 'beneficiarios_os_27_59_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3054, 'AJ', 'beneficiarios_os_18_26_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3053, 'AJ', 'beneficiarios_os_13_17_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3052, 'AJ', 'beneficiarios_os_6_12_fecha_recepcion'
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      48, 3051, 'AJ', 'beneficiarios_os_0_5_fecha_recepcion'
    )
  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3051)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3052)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3053)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3054)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3055)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3056)
    Heb412Gen::PlantillaHelper.elimina_columna(48, 3057)
  end

end
