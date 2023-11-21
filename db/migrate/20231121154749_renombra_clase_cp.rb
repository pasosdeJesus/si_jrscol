class RenombraClaseCp < ActiveRecord::Migration[7.0]

  include Msip::SqlHelper

  def change
    rename_column :msip_oficina, :clase_id, :centropoblado_id
    rename_column :territorial, :clase_id, :centropoblado_id

    renombrar_índice_pg(
      "msip_ubicacionpre_clase_id_idx", "msip_ubicacionpre_centropoblado_id_idx"
    )
    renombrar_índice_pg(
      "msip_ubicacionpre_pais_id_departamento_id_municipio_id_clase_id", 
      "msip_ubicacionpre_pais_id_departamento_id_municipio_id_centropoblado_id",
    )
  end
end
