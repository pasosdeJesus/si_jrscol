class PersonaCamposMigra < ActiveRecord::Migration[7.0]
  def change
    add_column :sip_persona, :ultimoperfilorgsocial_id, :integer
    add_foreign_key :sip_persona, :sip_perfilorgsocial, column: :ultimoperfilorgsocial_id

    add_column :sip_persona, :ultimoestatusmigratorio_id, :integer
    add_foreign_key :sip_persona, :sivel2_sjr_statusmigratorio, 
      column: :ultimoestatusmigratorio_id

    add_column :sip_persona, :ppt, :string, limit: 32

  end
end
