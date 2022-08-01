class AgregaOficinahist < ActiveRecord::Migration[7.0]
  def change
    add_column :asesorhistorico, :oficina_id, :integer
    add_foreign_key :asesorhistorico, :sip_oficina, column: :oficina_id
  end
end
