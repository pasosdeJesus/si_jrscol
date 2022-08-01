class AgregaFechainiasesor < ActiveRecord::Migration[7.0]
  def change
    add_column :sivel2_sjr_casosjr, :asesorfechaini, :date
  end
end
