# Ejecutar con bin/cron_diario

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

def notificar_mantenimiento(resultado)
    puts "Enviando correo sobre mantenimiento realizado:"
    puts resultado
    begin
      NotificacionMailer.with(
        resultado: resultado
      ).
      notificar_mantenimiento.deliver_now
    rescue => e
      puts "** No se pudo enviar correo (#{e.to_s})"
    end
end

def arreglar_poblacion
  resultados = ''
  numdif = ::ConteosHelper.arregla_tablas_poblacion_desde_2020(resultados)
  puts resultados

  if numdif > 0
    puts "Se hicieron #{numdif} correcciones, enviando correo"
    notificar_mantenimiento(resultados)
  end
end

def run
  if !ENV['SMTP_MAQ']
    puts "No esta definida variable de ambiente SMTP_MAQ"
    exit 1
  end
  arreglar_poblacion
  eliminar_generados
  m = Jos19::UnificarHelper.eliminar_casos_en_blanco
  puts m;
  m = Jos19::UnificarHelper.eliminar_personas_en_blanco
  puts m;
  m = Jos19::UnificarHelper.arreglar_casos_medio_borrados
  puts m;
  Msip::Persona.connection.execute <<-SQL
    REFRESH MATERIALIZED VIEW sivel2_gen_conscaso;
  SQL
end

run
