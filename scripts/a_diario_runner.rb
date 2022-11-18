# Ejecutar con bin/cron_diario

def notificar
  puts "Inicio de verificacion notificaciones"
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

def envia_alerta_mantenimiento(resultado)
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

def arregla_poblacion
  resultados = ''
  numdif = Cor1440Gen::ConteosHelper.arregla_tablas_poblacion_desde_2020(resultados)
  puts resultados

  if numdif > 0
    puts "Se hicieron #{numdif} correcciones, enviando correo"
    evia_alerta_mantenimiento(resultados)
  end
end

def run
  if !ENV['SMTP_MAQ']
    puts "No esta definida variable de ambiente SMTP_MAQ"
    exit 1
  end
  notificar
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
  arregla_poblacion
end

run
