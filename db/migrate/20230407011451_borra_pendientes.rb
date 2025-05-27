# frozen_string_literal: true

class BorraPendientes < ActiveRecord::Migration[7.0]
  def change
    remove_column(:sivel2_sjr_desplazamiento, :id_expulsion_porborrar, :integer)
    remove_column(:sivel2_sjr_desplazamiento, :id_llegada_porborrar, :integer)

    remove_column(:sivel2_sjr_migracion, :salida_pais_id_porborrar, :integer)
    remove_column(
      :sivel2_sjr_migracion,
      :salida_departamento_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :salida_municipio_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :salida_clase_id_porborrar,
      :integer,
    )
    remove_column(:sivel2_sjr_migracion, :llegada_pais_id_porborrar, :integer)
    remove_column(
      :sivel2_sjr_migracion,
      :llegada_departamento_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :llegada_municipio_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :llegada_clase_id_porborrar,
      :integer,
    )
    remove_column(:sivel2_sjr_migracion, :destino_pais_id_porborrar, :integer)
    remove_column(
      :sivel2_sjr_migracion,
      :destino_departamento_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :destino_municipio_id_porborrar,
      :integer,
    )
    remove_column(
      :sivel2_sjr_migracion,
      :destino_clase_id_porborrar,
      :integer,
    )
  end
end
