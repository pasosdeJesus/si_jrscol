class Docnonulo < ActiveRecord::Migration[7.0]
  def change
    change_column_null :sip_persona, :tdocumento_id, false
    #change_column_null :sip_persona, :numerodocumento, false
    change_column_null :sip_persona, :nombres, false
    change_column_null :sip_persona, :apellidos, false
  end
end
