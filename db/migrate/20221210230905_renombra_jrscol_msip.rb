class RenombraJrscolMsip < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  TAB = [
    ["sip_claverespaldo", "msip_claverespaldo"],
    ["sip_datosbio", "msip_datosbio"],
    ["sip_etiqueta_persona", "msip_etiqueta_persona"],
    ["sip_lineaorgsocial", "msip_lineaorgsocial"],
    ["sip_tipoanexo", "msip_tipoanexo"],
    ["sip_tipoorgsocial", "msip_tipoorgsocial"],
  ]

  IND = [
    ["sip_persona_numerodocumento_idx", "msip_persona_numerodocumento_idx"],
    ["sip_persona_tdocumento_id_idx", "msip_persona_tdocumento_id_idx"],
    ["sip_ubicacionpre_clase_id_idx", "msip_ubicacionpre_clase_id_idx"],
    ["sip_ubicacionpre_departamento_id_idx", 
     "msip_ubicacionpre_departamento_id_idx"],
    ["sip_ubicacionpre_municipio_id_idx", "msip_ubicacionpre_municipio_id_idx"],
    ["sip_ubicacionpre_pais_id_idx", "msip_ubicacionpre_pais_id_idx"],
    ["sip_ubicacionpre_pais_id_departamento_id_idx",
     "msip_ubicacionpre_pais_id_departamento_id_idx"],
    ["sip_ubicacionpre_pais_id_departamento_id_municipio_id_idx",
     "msip_ubicacionpre_pais_id_departamento_id_municipio_id_idx"],
    ["sip_ubicacionpre_pais_id_departamento_id_municipio_id_clase_idx",
     "msip_ubicacionpre_pais_id_departamento_id_municipio_id_clase_idx"],
    ["sip_ubicacionpre_tsitio_id_idx", "msip_ubicacionpre_tsitio_id_idx"],
  ]

  def change
    TAB.each do |nomini, nomfin|
      rename_table(nomini, nomfin)
    end
    IND.each do |nomini, nomfin|
      renombrar_índice_pg(nomini, nomfin)
    end
  end

end
