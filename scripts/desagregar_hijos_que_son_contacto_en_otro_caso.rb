# frozen_string_literal: true

require 'csv'

contactos_desagregados = 0
beneficiarios_desagregados = 0
CSV.foreach('por-procesa-mismo-benef.csv', headers: true) do |row|
  # Acceder a columnas por nombre
  persona_id = row['persona_id'].to_i
  caso_id = row['caso_id'].to_i
  v = Sivel2Gen::Victima.where(persona_id: persona_id)
  if (v.length == 2) then
    vsjr = [Sivel2Sjr::Victimasjr.where(victima_id: v[0])[0],
            Sivel2Sjr::Victimasjr.where(victima_id: v[1])[0]]

    if vsjr[0].fechadesagregacion.nil? && vsjr[1].fechadesagregacion.nil? 
      contacto = -1
      caso = [v[0].caso_id, v[1].caso_id]
      if (Sivel2Sjr::Casosjr.where(caso_id: caso[0])[0].contacto_id == persona_id)
        contacto = 0
      elsif (Sivel2Sjr::Casosjr.where(caso_id: caso[1])[0].contacto_id == persona_id)
        contacto = 1
      end
      if (contacto >= 0)
        otro = 1 - contacto
        if (vsjr[otro].rolfamilia_id && vsjr[otro].fechadesagregacion.nil? &&
            caso[otro] < caso[contacto])
          vsjr[otro].fechadesagregacion = Date.today
          contactos_desagregados += 1
          puts "Contact desagregado #{contactos_desagregados}."
          puts "#{row['nombres']} #{row['apellidos']} con id #{persona_id} es\n Contacto en caso #{caso[contacto]} pero #{vsjr[otro].rolfamilia.nombre} en caso #{caso[otro]}.\n Se desagrega del caso #{caso[otro]} que es anterior al #{caso[contacto]}"
          vsjr[otro].save
        else
          puts persona_id 
        end
      else
        # Una persona que esta en dos casos y no es contacto en nignuna,
        # suponemos que basta desagregarla del más antiguo
        queda = caso[0] < caso [1] ? 1 : 0
        otro = 1 - queda
        if (vsjr[otro].rolfamilia_id && vsjr[queda].rolfamilia_id)
          vsjr[otro].fechadesagregacion = Date.today
          beneficiarios_desagregados += 1
          puts "Beneficiario desagregado #{beneficiarios_desagregados}."
          puts "#{row['nombres']} #{row['apellidos']} con id #{persona_id} es\n #{vsjr[queda].rolfamilia.nombre} en caso #{caso[queda]} pero #{vsjr[otro].rolfamilia.nombre} en caso #{caso[otro]}.\n Se desagrega del caso #{caso[otro]} que es anterior al #{caso[queda]}"
          puts "ENTER para continuar..."
          STDIN.gets
          vsjr[otro].save
        else
          puts persona_id 
        end
      end
    else
      puts persona_id 
    end
  end
end
