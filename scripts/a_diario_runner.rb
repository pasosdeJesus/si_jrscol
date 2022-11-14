# Ejecutar con bin/cron_diario

def alertas
  puts "Inicio de verificacion alertas"
end

def eliminar_generados
    puts "Eliminando public/heb412/generados"
    orden = "ls -l public/heb412/generados/"
    res = `#{orden}`
    puts res
    orden = "rm public/heb412/generados/*ods"
    res = `#{orden}`
    puts res
    orden = "rm public/heb412/generados/*xlsx"
    res = `#{orden}`
    puts res
    orden = "rm public/heb412/generados/*pdf"
    res = `#{orden}`
    puts res
end

def cuenta_poblacion_0
  ap0 = Cor1440Gen::Actividad.all
  puts "Encontrando actividades con cuenta de poblacion en 0 entre las #{ap0.count}"
  ap0 = ap0.where('id IN (SELECT actividad_id FROM cor1440_gen_asistencia)')
  puts "Limitando a #{ap0.count} que tienen listaso de asistencia o listado de casos"
  univ = ap0.count
  c = 0
  ultp = -1
  ap0 = ap0.select do |a| 
    c += 1
    por = c*100/univ 
    if por / 10 != ultp / 10
      ultp = por
      puts "#{por}%"
    end
    a.presenta('poblacion') == 0
  end
  puts "Encontradas #{ap0.count} actividades con población pero cuenta de población en 0"
  ap0.each do |a|
    puts "Actividad sin asistencia: #{a.id}"
    personas = {}
    a.asistencia.each do |asist|
      personas[asist.persona.id] = 1
    end

    rangoedadsexo = {}
    personas.keys.sort.each do |pid|
      p = Sip::Persona.find(pid)
      edad = Sivel2Gen::RangoedadHelper.edad_de_fechanac_fecha(
        p.anionac, p.mesnac, p.dianac,
        a.fecha.year, a.fecha.month, a.fecha.day)
      re = Sivel2Gen::RangoedadHelper.buscar_rango_edad(
        edad, 'Cor1440Gen::Rangoedadac')
      if !rangoedadsexo[re]
        rangoedadsexo[re] = {}
      end
      if !rangoedadsexo[re][p.sexo]
        rangoedadsexo[re][p.sexo] = 0
      end
      rangoedadsexo[re][p.sexo] += 1
    end

    car = 0
    rangoedadsexo.each do |r, ds|
      ar = Cor1440Gen::ActividadRangoedadac.create(
        actividad_id: a.id,
        rangoedadac_id: r,
        ml: 0,
        mr: ds['M'] ? ds['M'] : 0,
        fl: 0,
        fr: ds['F'] ? ds['F'] : 0,
        s: ds['S'] ? ds['S'] : 0
      )
      ar.save!
      car += 1
    end
    puts "Añadidos #{car} registros en .._actividad_rangoedadac con actividad #{a.id}"
  end
end

def run
  if !ENV['SMTP_MAQ']
    puts "No esta definida variable de ambiente SMTP_MAQ"
    exit 1
  end
  alertas
  eliminar_generados
  m = UnificarHelper.eliminar_casos_en_blanco
  puts m;
  m = UnificarHelper.eliminar_personas_en_blanco
  puts m;
  m = UnificarHelper.arreglar_casos_medio_borrados
  puts m;
  Sip::Persona.connection.execute <<-SQL
    REFRESH MATERIALIZED VIEW sivel2_gen_conscaso;
  SQL
  cuenta_poblacion_0
end

run
