class PrNombreRes1612 < ActiveRecord::Migration[7.0]

  def up
    add_column :sivel2_gen_presponsable, :nombre_res1612, :string, limit: 128

    execute <<-SQL
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'Fuerza Pública' WHERE id=2; -- Fuerza Pública
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'ELN' where id=28; -- ELN
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'EPL' where id=31; -- EPL
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'Disidencias de las FARC-EP' WHERE id=111; -- Discidencias
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'Grupos armados post desmovilización o estructuras armadas locales' WHERE id=14; -- Paramilitares
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'Grupos armados sin identificar' where id=35; -- SIN INFORMACIÓN
      UPDATE sivel2_gen_presponsable
        SET nombre_res1612 = 'Otros' WHERE id=36; -- Otros
    SQL
  end
  def down
    remove_column :sivel2_gen_presponsable, :nombre_res1612, :string, limit: 128
  end

end
