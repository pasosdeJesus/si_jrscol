class Actonino < ActiveRecord::Migration[7.0]
  def change
    create_table :actonino do |t|
      t.integer :caso_id, null: false
      t.date :fecha, null: false
      t.integer :ubicacionpre_id, null: false
      t.integer :presponsable_id, null: false
      t.integer :categoria_id, null: false
      t.integer :persona_id, null: false

      t.timestamps
    end

    add_foreign_key :actonino, :sivel2_gen_caso, column: :caso_id
    add_foreign_key :actonino, :msip_ubicacionpre, column: :ubicacionpre_id
    add_foreign_key :actonino, :sivel2_gen_presponsable, 
      column: :presponsable_id
    add_foreign_key :actonino, :sivel2_gen_categoria, column: :categoria_id
    add_foreign_key :actonino, :msip_persona, column: :persona_id
  end
end
