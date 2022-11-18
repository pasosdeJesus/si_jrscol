class AjustaTablasPoblacion < ActiveRecord::Migration[7.0]
  def up
    resultados = ''
    numdif = Cor1440Gen::ConteosHelper.arregla_tablas_poblacion_desde_2020(
      resultados
    )

    puts resultados

    if numdif > 0
      puts "Se hicieron #{numdif} correcciones"
    end
  end

  def down
  end
end
