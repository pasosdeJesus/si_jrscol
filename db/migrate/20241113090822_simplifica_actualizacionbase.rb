# frozen_string_literal: true

class SimplificaActualizacionbase < ActiveRecord::Migration[7.2]
  def up
    drop_table(:sivel2_sjr_actualizacionbase)
    drop_table(:sivel2_sjr_instanciader)
    drop_table(:sivel2_sjr_mecanismoder)
    drop_table(:sivel2_sjr_resagresion)
  end
end
