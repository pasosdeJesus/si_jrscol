# frozen_string_literal: true

class SincronizaUbicacionpre < ActiveRecord::Migration[7.0]
  def up
    pf = Msip::Pais.where(
      "id NOT IN (SELECT DISTINCT pais_id FROM msip_ubicacionpre " \
        "WHERE pais_id IS NOT NULL)",
    ).order(:id)
    puts "* Paises que faltan: #{pf.count}."
    if pf.count == 1
      puts "  Con id #{pf[0].id} (#{pf[0].nombre})"
    elsif pf.count > 1
      puts "  Comenzando con id #{pf[0].id} (#{pf[0].nombre})  " \
        "y terminando con id #{pf[-1].id} (#{pf[-1].nombre})"
    end
    if pf.count > 0
      execute(<<-SQL)
        INSERT INTO msip_ubicacionpre (id, pais_id, nombre, nombre_sin_pais,#{" "}
          latitud, longitud, created_at, updated_at)#{" "}
          (SELECT msip_ubicacionpre_id_rtablabasica(), p.id,#{" "}
            (msip_ubicacionpre_nomenclatura(p.nombre, null, null, null, null, null, null))[1],
            (msip_ubicacionpre_nomenclatura(p.nombre, null, null, null, null, null, null))[2],
          p.latitud, p.longitud, NOW(), NOW() FROM msip_pais AS p WHERE
          p.id NOT in (SELECT DISTINCT pais_id FROM msip_ubicacionpre#{" "}
            WHERE pais_id IS NOT NULL));
      SQL
    end

    df = Msip::Departamento.where(
      "id NOT IN (SELECT DISTINCT departamento_id FROM msip_ubicacionpre " \
        "WHERE departamento_id IS NOT NULL)",
    ).order(:id)
    puts "* Departamentos que faltan: #{df.count}."
    if df.count == 1
      puts "  Con id #{df[0].id} (#{df[0].nombre})"
    elsif df.count > 1
      puts "  Comenzando con id #{df[0].id} (#{df[0].nombre})  " \
        "y terminando con id #{df[-1].id} (#{df[-1].nombre})"
    end
    if df.count > 0
      execute(<<-SQL)
        INSERT INTO msip_ubicacionpre (id, pais_id, departamento_id,
          nombre, nombre_sin_pais,#{" "}
          latitud, longitud, created_at, updated_at)#{" "}
          (SELECT msip_ubicacionpre_id_rtablabasica(), p.id, d.id,
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, null, null, null, null, null))[1],
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, null, null, null, null, null))[2],
          d.latitud, d.longitud, NOW(), NOW() FROM msip_departamento AS d
          JOIN msip_pais AS p ON d.pais_id=p.id#{" "}
          WHERE d.id NOT in (SELECT DISTINCT departamento_id
            FROM msip_ubicacionpre WHERE departamento_id IS NOT NULL));
      SQL
    end

    mf = Msip::Municipio.where(
      "id NOT IN (SELECT DISTINCT municipio_id FROM msip_ubicacionpre " \
        "WHERE municipio_id IS NOT NULL)",
    ).order(:id)
    puts "* Municipios que faltan: #{mf.count}."
    if mf.count == 1
      puts "  Con id #{mf[0].id} (#{mf[0].nombre})"
    elsif mf.count > 1
      puts "  Comenzando con id #{mf[0].id} (#{mf[0].nombre})  " \
        "y terminando con id #{mf[-1].id} (#{mf[-1].nombre})"
    end
    if mf.count > 0
      execute(<<-SQL)
        INSERT INTO msip_ubicacionpre (id, pais_id, departamento_id,#{" "}
          municipio_id, nombre, nombre_sin_pais,#{" "}
          latitud, longitud, created_at, updated_at)#{" "}
          (SELECT msip_ubicacionpre_id_rtablabasica(), p.id, d.id, m.id,
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, null, null, null))[1],
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, null, null, null))[2],
          m.latitud, m.longitud, NOW(), NOW() FROM msip_municipio AS m
          JOIN msip_departamento AS d ON m.departamento_id=d.id
          JOIN msip_pais AS p ON d.pais_id=p.id#{" "}
          WHERE m.id NOT in (SELECT DISTINCT municipio_id#{" "}
            FROM msip_ubicacionpre WHERE municipio_id IS NOT NULL));
      SQL
    end

    cf = Msip::Centropoblado.where(
      "id NOT IN (SELECT DISTINCT centropoblado_id FROM msip_ubicacionpre " \
        "WHERE centropoblado_id IS NOT NULL)",
    ).order(:id)
    puts "* Centros poblados que faltan: #{cf.count}."
    if cf.count == 1
      puts "  Con id #{cf[0].id} (#{cf[0].nombre})"
    elsif cf.count > 1
      puts "  Comenzando con id #{cf[0].id} (#{cf[0].nombre})  " \
        "y terminando con id #{cf[-1].id} (#{cf[-1].nombre})"
    end
    if cf.count > 0
      execute(<<-SQL)
        INSERT INTO msip_ubicacionpre (id, pais_id, departamento_id,#{" "}
          municipio_id, centropoblado_id, nombre, nombre_sin_pais,#{" "}
          latitud, longitud, created_at, updated_at)#{" "}
          (SELECT msip_ubicacionpre_id_rtablabasica(), p.id, d.id, m.id, c.id,
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, c.nombre, null, null))[1],
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, null, c.nombre, null, null))[2],
          c.latitud, c.longitud, NOW(), NOW() FROM msip_centropoblado as c
          JOIN msip_municipio AS m ON c.municipio_id=m.id
          JOIN msip_departamento AS d ON m.departamento_id=d.id
          JOIN msip_pais AS p ON d.pais_id=p.id#{" "}
          WHERE c.id NOT in (SELECT DISTINCT centropoblado_id#{" "}
            FROM msip_ubicacionpre WHERE centropoblado_id IS NOT NULL))
      SQL
    end

    vf = Msip::Vereda.where(
      "id NOT IN (SELECT DISTINCT vereda_id FROM msip_ubicacionpre " \
        "WHERE vereda_id IS NOT NULL)",
    ).order(:id)
    puts "* Veredas que faltan: #{vf.count}."
    if vf.count == 1
      puts "  Con id #{vf[0].id} (#{vf[0].nombre})"
    elsif vf.count > 1
      puts "  Comenzando con id #{vf[0].id} (#{vf[0].nombre})  " \
        "y terminando con id #{vf[-1].id} (#{vf[-1].nombre})"
    end
    if vf.count > 0
      execute(<<-SQL)
        INSERT INTO msip_ubicacionpre (id, pais_id, departamento_id,#{" "}
          municipio_id, vereda_id, nombre, nombre_sin_pais,#{" "}
          latitud, longitud, created_at, updated_at)#{" "}
          (SELECT msip_ubicacionpre_id_rtablabasica(), p.id, d.id, m.id, v.id,
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, v.nombre, null, null, null))[1],
            (msip_ubicacionpre_nomenclatura(p.nombre, d.nombre, m.nombre, v.nombre, null, null, null))[2],
          v.latitud, v.longitud, NOW(), NOW() FROM msip_vereda as v
          JOIN msip_municipio AS m ON v.municipio_id=m.id
          JOIN msip_departamento AS d ON m.departamento_id=d.id
          JOIN msip_pais AS p ON d.pais_id=p.id#{" "}
          WHERE v.id NOT in (SELECT DISTINCT vereda_id#{" "}
            FROM msip_ubicacionpre WHERE vereda_id IS NOT NULL));
      SQL
    end
  end

  def down
  end
end
