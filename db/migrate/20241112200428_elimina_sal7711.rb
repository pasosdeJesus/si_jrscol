class EliminaSal7711 < ActiveRecord::Migration[7.2]
  def up
    drop_table :sal7711_gen_bitacora
    drop_table :sal7711_gen_articulo_categoriaprensa
    drop_table :sal7711_gen_categoriaprensa
    drop_table :sal7711_gen_articulo
  end
end
