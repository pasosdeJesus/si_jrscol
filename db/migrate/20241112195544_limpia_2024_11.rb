class Limpia202411 < ActiveRecord::Migration[7.2]
  def up
    remove_foreign_key :sivel2_sjr_respuesta, :causaref, column: :causaref_id
    drop_table :causaref
  end
end
