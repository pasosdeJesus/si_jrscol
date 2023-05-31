# Ejecutar con bin/cron_diario

def arreglar_poblacion
  resultados = ''
  numdif = ::ConteosHelper.arreglar_tablas_poblacion_desde_2020(resultados)
  puts resultados

  if numdif > 0
    puts "Se hicieron #{numdif} correcciones"
    notificar_mantenimiento(resultados)
  end
end

arreglar_poblacion
