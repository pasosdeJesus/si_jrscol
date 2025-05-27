# frozen_string_literal: true

class MsipParamVistam < ActiveRecord::Migration[7.0]
  def up
    create_table(:msip_params_vistam) do |t|
      t.string(:vistam, limit: 128)
      t.integer(:usuario_id) # Quien la creó
      t.json(:params)
      t.timestamp(:marcadetiempo)
    end
  end

  def down
    drop_table(:msip_params_vistam)
  end
end
