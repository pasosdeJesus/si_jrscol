class CambiaNombresMsip < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  IND = [
    ["sivel2_gen_anexoactividad_pkey", "sip_anexo_pkey"],
  ]

  def change
    IND.each do |nomini, nomfin| 
      renombrar_índice_pg(nomini, nomfin)
    end
  end

end
