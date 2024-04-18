class Asociadiscapacidadpersona < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :msip_persona, :discapacidad, column: :ultimadiscapacidad_id
  end
end
