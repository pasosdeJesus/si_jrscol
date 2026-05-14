# frozen_string_literal: true

require 'did_you_mean/levenshtein'

total = Msip::Anexo.all.count
ultper = -1
cuenta = 0
renom = 0
noenc = 0
Msip::Anexo.all.each do |anexo|
  nom = File.basename(anexo.adjunto_file_name)
  if !nom.nil?
    ruta = format(
      Msip.ruta_anexos.to_s + "/%d_%s",
      anexo.id.to_i,
      nom
    )
    if !File.exist?(ruta)
      puts "No existe #{ruta}"
      nomp = `ls #{File.join(Msip.ruta_anexos.to_s, anexo.id.to_s)}_*`.chomp
      puts nomp
      if nomp.include?("\n")
        puts "Muchos"
        mindist = -1
        minind = -1
        ind = 0
        nompl = nomp.split("\n")
        nompl.each do |pnom|
          distance = DidYouMean::Levenshtein.distance(pnom, ruta)
          puts "OJO pnom=#{pnom}, distance=#{distance}"
          if (mindist == -1 || distance < mindist) 
            mindist = distance
            minind = ind
          end
          ind =+1
        end
        if (minind < 0) 
          puts "No se encontró minimo"
          exit 1
        end
        rutaex = nompl[minind]
      else
        rutaex = nomp
      end
      puts "rutaex='#{rutaex}'"
      if rutaex == ruta || rutaex.to_s == ""
        puts "No se encontró anexo #{ruta}"
        noenc += 1
      else
        puts "mv #{rutaex} #{ruta}"
        File.rename(rutaex, ruta)
        renom += 1
      end
    end
    cuenta += 1
    if (cuenta*100/total > ultper)
      ultper = cuenta*100/total
      puts "#{ultper}%"
    end
  end
end
puts "Total renombramientos: #{renom}"
puts "Total no encontrados: #{noenc}"
