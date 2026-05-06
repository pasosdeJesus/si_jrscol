class EliminaRefDiscapacidadErradas < ActiveRecord::Migration[7.2]
  def change
    remove_column :sivel2_sjr_victimasjr, :discapacidad_id, :integer
    remove_column :cor1440_gen_asistencia, :discapacidad, :boolean
  end
end
