# frozen_string_literal: true

class OtroSexoInfoUltimaAtencion < ActiveRecord::Migration[7.0]
  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2739, "AD", "ultimaatencion_beneficiarios_os_se"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2738, "AD", "ultimaatencion_beneficiarios_os_60m"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2737, "AD", "ultimaatencion_beneficiarios_os_27_59"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2736, "AD", "ultimaatencion_beneficiarios_os_18_26"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2735, "AD", "ultimaatencion_beneficiarios_os_13_17"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2734, "AD", "ultimaatencion_beneficiarios_os_6_12"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      1, 2733, "AD", "ultimaatencion_beneficiarios_os_0_5"
    )
  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2733)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2734)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2735)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2736)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2737)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2738)
    Heb412Gen::PlantillaHelper.elimina_columna(1, 2739)
  end
end
