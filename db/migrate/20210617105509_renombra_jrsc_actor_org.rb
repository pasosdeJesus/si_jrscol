class RenombraJrscActorOrg < ActiveRecord::Migration[6.1]
  def change
    rename_table :sip_lineaactorsocial, :sip_lineaorgsocial
    rename_table :sip_tipoactorsocial, :sip_tipoorgsocial
    rename_column :sip_orgsocial, :tipoactorsocial_id, :tipoorgsocial_id
    rename_column :sip_orgsocial, :lineaactorsocial_id, :lineaorgsocial_id
  end
end
