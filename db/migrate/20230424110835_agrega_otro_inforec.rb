# frozen_string_literal: true

class AgregaOtroInforec < ActiveRecord::Migration[7.0]
  def up
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2837, "AC", "beneficiarios_os_se_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2836, "AC", "beneficiarios_os_60m_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2835, "AC", "beneficiarios_os_27_59_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2834, "AC", "beneficiarios_os_18_26_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2833, "AC", "beneficiarios_os_13_17_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2832, "AC", "beneficiarios_os_6_12_fecha_recepcion"
    )
    Heb412Gen::PlantillaHelper.inserta_columna(
      47, 2831, "AC", "beneficiarios_os_0_5_fecha_recepcion"
    )
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_consexpcaso CASCADE;
    SQL
  end

  def down
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2831)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2832)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2833)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2834)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2835)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2836)
    Heb412Gen::PlantillaHelper.elimina_columna(47, 2837)
    execute(<<-SQL)
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_consexpcaso CASCADE;
    SQL
  end
end
