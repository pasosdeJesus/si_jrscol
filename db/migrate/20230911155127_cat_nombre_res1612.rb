# frozen_string_literal: true

class CatNombreRes1612 < ActiveRecord::Migration[7.0]
  def up
    add_column(:sivel2_gen_categoria, :nombre_res1612, :string, limit: 128)

    execute(<<-SQL)
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'RECLUTAMIENTO DE NNA' where id=3020; -- RECLUTAMIENTO DE NNA
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'USO DE NNA' where id=3021; -- USO DE NNA
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'ASESINATO' where id=3000; -- HOMICIDIO EN PERSONA PROTEGIDA
      INSERT INTO sivel2_gen_categoria (id, nombre, nombre_res1612, tipocat, supracategoria_id,
        fechacreacion, created_at, updated_at) VALUES
        (3023, 'MUTILACIÓN', 'MUTILACIÓN', 'I', 100,#{" "}
         '2023-09-11', '2023-09-11', '2023-09-11');
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'LESIONES PERSONALES' where id=3004; -- HERIDAS
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'TORTURA Y TRATOS INHUMANOS, CRUELES Y DEGRADANTES' WHERE id=3003; -- TORTURA Y TRATOS INHUMANOS, CRUELES Y DEGRADANTES
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'TORTURA Y TRATOS INHUMANOS, CRUELES Y DEGRADANTES' WHERE id=3003; -- TORTURA Y TRATOS INHUMANOS, CRUELES Y DEGRADANTES
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'VIOLENCIA SEXUAL' WHERE id=3005; -- VIOLENCIA SEXUAL
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'SECUESTRO' WHERE id=3012; -- SECUESTRO
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'ATAQUE A ESCUELA O A HOSPITAL' WHERE id=3517; -- ATAQUE O USO DE UN BIEN CIVIL
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'ATAQUE A ESCUELA O A HOSPITAL' WHERE id=3517; -- ATAQUE O USO DE UN BIEN CIVIL
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'DESAPARICIÓN FORZADA' WHERE id=3006; -- DESAPARICIÓN FORZADA
      UPDATE sivel2_gen_categoria
        SET nombre_res1612 = 'DESPLAZAMIENTO FORZADO' WHERE id=3509; -- DESPLAZAMIENTO FORZADO
      INSERT INTO sivel2_gen_categoria (id, nombre, nombre_res1612, tipocat, supracategoria_id,
        fechacreacion, created_at, updated_at) VALUES
        (3024, 'OTRO', 'OTRO', 'I', 100,
         '2023-09-11', '2023-09-11', '2023-09-11');
    SQL
  end

  def down
    remove_column(:sivel2_gen_categoria, :nombre_res1612, :string, limit: 128)
    execute(<<-SQL)
      DELETE FROM sivel2_gen_categoria WHERE id IN (3023, 3024);
    SQL
  end
end
