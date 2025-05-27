# frozen_string_literal: true

class RenombraPptObsoleto < ActiveRecord::Migration[7.0]
  def change
    rename_column(:msip_persona, :ppt, :ppt_obsoleto)
  end
end
