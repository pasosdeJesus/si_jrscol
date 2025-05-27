# frozen_string_literal: true

class IndicesUnicidad < ActiveRecord::Migration[7.0]
  def change
    add_index(:docidsecundario, [:persona_id, :tdocumento_id], unique: true)
    add_index(:docidsecundario, [:tdocumento_id, :numero], unique: true)
  end
end
