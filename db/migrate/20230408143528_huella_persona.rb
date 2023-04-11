class HuellaPersona < ActiveRecord::Migration[7.0]
  def change
    add_column :msip_persona, :huella, :string, limit: 1024
  end
end
