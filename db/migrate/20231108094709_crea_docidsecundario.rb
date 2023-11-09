class CreaDocidsecundario < ActiveRecord::Migration[7.0]
  def change
    create_table :docidsecundario do |t|
      t.integer :persona_id, null: false
      t.integer :tdocumento_id, null: false
      t.string :numero, null: false, limit: 100

      t.timestamps
    end
    add_foreign_key :docidsecundario, :msip_persona, column: :persona_id
    add_foreign_key :docidsecundario, :msip_tdocumento, column: :tdocumento_id
  end
end
