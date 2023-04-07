class ConvNomRails < ActiveRecord::Migration[7.0]
  def change
    rename_column :sivel2_sjr_casosjr, :id_salidam, :salidam_id
    rename_column :sivel2_sjr_casosjr, :id_llegadam, :llegadam_id
    rename_column :sivel2_sjr_respuesta, :id_causaref, :causaref_id
  end
end
