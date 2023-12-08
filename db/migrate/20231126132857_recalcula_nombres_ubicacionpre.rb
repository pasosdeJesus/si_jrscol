class RecalculaNombresUbicacionpre < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      --Paises
      UPDATE msip_ubicacionpre SET
        nombre=(msip_ubicacionpre_nomenclatura(p.nombre, null, null, null, null, lugar, sitio))[1],
        nombre_sin_pais=(msip_ubicacionpre_nomenclatura(p.nombre, null, null, null, null, lugar, sitio))[2]
      FROM msip_pais AS p 
      WHERE p.id=msip_ubicacionpre.pais_id 
      AND msip_ubicacionpre.departamento_id IS NULL;
    SQL
    execute <<-SQL

      UPDATE msip_ubicacionpre SET
        nombre=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, null, null, null, lugar, sitio))[1],
        nombre_sin_pais=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, null, null, null, lugar, sitio))[2]
      FROM msip_pais AS p
      JOIN msip_departamento AS d ON d.pais_id=p.id
      WHERE p.id=msip_ubicacionpre.pais_id
      AND d.id=msip_ubicacionpre.departamento_id
      AND msip_ubicacionpre.municipio_id IS NULL;

    SQL
    execute <<-SQL
      UPDATE msip_ubicacionpre SET
        nombre=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, null, lugar, sitio))[1],
        nombre_sin_pais=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, null, lugar, sitio))[2]
      FROM msip_pais AS p
      JOIN msip_departamento AS d ON d.pais_id=p.id
      JOIN msip_municipio AS m ON m.departamento_id=d.id
      WHERE p.id=msip_ubicacionpre.pais_id
      AND d.id=msip_ubicacionpre.departamento_id
      AND m.id=msip_ubicacionpre.municipio_id
      AND msip_ubicacionpre.centropoblado_id IS NULL AND vereda_id IS NULL;

    SQL
    execute <<-SQL
      UPDATE msip_ubicacionpre SET
        nombre=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, c.nombre, lugar, sitio))[1],
        nombre_sin_pais=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, c.nombre, lugar, sitio))[2]
      FROM msip_pais AS p
      JOIN msip_departamento AS d ON d.pais_id=p.id
      JOIN msip_municipio AS m ON m.departamento_id=d.id
      JOIN msip_centropoblado AS c ON c.municipio_id=m.id
      WHERE p.id=msip_ubicacionpre.pais_id 
      AND d.id=msip_ubicacionpre.departamento_id
      AND m.id=msip_ubicacionpre.municipio_id
      AND c.id=msip_ubicacionpre.centropoblado_id;

    SQL
    execute <<-SQL
      UPDATE msip_ubicacionpre SET
        nombre=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, v.nombre, null, lugar, sitio))[1],
        nombre_sin_pais=(msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, v.nombre, null, lugar, sitio))[2]
      FROM msip_pais AS p
      JOIN msip_departamento AS d ON d.pais_id=p.id
      JOIN msip_municipio AS m ON m.departamento_id=d.id
      JOIN msip_vereda AS v ON v.municipio_id=m.id
      WHERE p.id=msip_ubicacionpre.pais_id 
      AND d.id=msip_ubicacionpre.departamento_id
      AND m.id=msip_ubicacionpre.municipio_id
      AND v.id=msip_ubicacionpre.vereda_id;
    SQL
  end
  def down
  end
end
