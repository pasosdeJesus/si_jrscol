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

def arregla_poblacion
  resultados = ''
  numdif = Cor1440Gen::ConteosHelper.arregla_tablas_poblacion_desde_2020(resultados)
  puts resultados

  if numdif > 0
    puts "Se hicieron #{numdif} correcciones, enviando correo"
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
