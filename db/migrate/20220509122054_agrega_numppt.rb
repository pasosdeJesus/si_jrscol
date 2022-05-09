class AgregaNumppt < ActiveRecord::Migration[7.0]
  def change
    add_column :sivel2_sjr_migracion, :numppt, :string, limit: 32
  end
end
