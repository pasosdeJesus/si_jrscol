# frozen_string_literal: true

# Ejecutar con bin/cron_diario

def arreglar_poblacion
  resultados = ""
  numdif = ConteosHelper.arreglar_tablas_poblacion_desde_2020(resultados)
  puts resultados

  if numdif > 0
    puts "Se hicieron #{numdif} correcciones"
  end
end

arreglar_poblacion
