class AgregaAyudaATdocumento < ActiveRecord::Migration[6.1]
  def change
    add_column :sip_tdocumento, :ayuda, :string, limit: 1000
  end
end
