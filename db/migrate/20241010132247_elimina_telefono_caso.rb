class EliminaTelefonoCaso < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso;
    SQL
    remove_column :sivel2_sjr_casosjr, :telefono, :string
  end
  def down
    add_column :sivel2_sjr_casosjr, :telefono, :string, limit: 127
  end

end
