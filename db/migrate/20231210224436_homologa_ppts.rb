class HomologaPpts < ActiveRecord::Migration[7.0]
  def up
    numprin = 0
    numsec = 0
    numprob = 0
    puts "Id,Sigla,Número de documento,PPT,Razón por la que fue descartado"
    Msip::Persona.where.not(ppt: nil).where("TRIM(ppt)<>''").each do |p|
      prob = ""
      if p[:ppt] && p[:ppt].strip.match(/^[0-9]+$/)
        if p[:ppt].strip != p.numerodocumento
          if Msip::Persona.where(tdocumento_id: 16).
              where(numerodocumento: p[:ppt].strip).count == 0
            if Docidsecundario.where(tdocumento_id: 16).
                where(numero: p[:ppt].strip).count == 0
              if p.tdocumento_id == 11 # SIN DOCUMENTO
                p.tdocumento_id = 16
                p.numerodocumento = p[:ppt]
                numprin += 1
              else
                ds = Docidsecundario.new(
                  tdocumento_id: 16,
                  numero: p[:ppt].strip,
                  persona_id: p.id
                )
                ds.save
                numsec += 1
              end
            else
              prob = "Duplicado como documento de identidad secundario de "\
                "persona con id: " + Docidsecundario.
                where(tdocumento_id: 16).where(numero:p[:ppt].strip).
                pluck(:persona_id).join(", ")
            end
          else
            prob = "Duplicado como documento de identidad primario de "\
                "persona con id: " + Msip::Persona.
                where(tdocumento_id: 16).where(numerodocumento:p[:ppt].strip).
                pluck(:id).join(", ")
          end
        else
          prob = "Documento principal igual al PPT"
        end
      else
        prob = "PPT no consta de sólo números"
      end
      if prob != ""
        puts "#{p.id},#{p.tdocumento.sigla},#{p.numerodocumento},#{p[:ppt]},#{prob}"
        numprob += 1
      end
    end
    STDERR.puts "PPT homologado como documento principal de #{numprin} personas"
    STDERR.puts "PPT homologado como documento secundario de #{numsec} personas"
    STDERR.puts "PPT descartado de #{numprob} personas"
  end
  def down
    raise IrreversibleMigration
  end
end
