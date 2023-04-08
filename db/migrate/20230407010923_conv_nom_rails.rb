class ConvNomRails < ActiveRecord::Migration[7.0]
  def up
    rename_column :sivel2_sjr_casosjr, :id_salidam, :salidam_id
    rename_column :sivel2_sjr_casosjr, :id_llegadam, :llegadam_id
    if Sivel2Sjr::Respuesta.columns.map(&:name).include?("id_causaref")
      rename_column :sivel2_sjr_respuesta, :id_causaref, :causaref_id
    end
  end
  def down
    rename_column :sivel2_sjr_casosjr, :salidam_id, :id_salidam
    rename_column :sivel2_sjr_casosjr, :llegadam_id, :id_llegadam
    if Sivel2Sjr::Respuesta.columns.map(&:name).include?("causaref_id")
      rename_column :sivel2_sjr_respuesta, :causaref, :id_causaref
    end
  end
end
