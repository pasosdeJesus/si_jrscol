# frozen_string_literal: true

require 'fileutils'
require 'time'

# Actualiza respaldo de anexos
# La deja en carpeta Respaldos de la nube
# Para el cifrado y compresión usa 7z
# Como clave de cifrado usa la que tenga mayor id de la tabla
# msip_claverespaldo

unless ENV["HEB412_RUTA"]
  puts "Falta variable de entorno HEB412_RUTA"
  exit 1
end
nube = ENV["HEB412_RUTA"]

unless ENV["MSIP_RUTA_ANEXOS"]
  puts "Falta variable de entorno MSIP_RUTA_ANEXOS"
  exit 1
end
anexos = ENV["MSIP_RUTA_ANEXOS"]
#puts "OJO anexos=#{anexos}"
#puts "OJO expand=#{File.expand_path(anexos)}"
papaanexos = File.dirname(File.expand_path(anexos))
#puts "OJO papaanexos=#{papaanexos}"


# https://stackoverflow.com/questions/690151/getting-output-of-system-calls-in-ruby
def ejecutar_en_shell(*cmd)
  puts "OJO ejecutar_en_shell(", cmd.join(" "), ")"
  stdout, stderr, status = Open3.capture3(*cmd)
  status.success? && stdout.slice!(0..-(1 + $/.size)) # strip trailing eol
  puts stdout
  puts stderr
  puts status
rescue => e
  STDERR.puts "Error: ", e
end


salida = "#{nube}/Respaldos/anexos.7z"
# Ojo mejor que la clave no tenga caracteres por escapar que podrían
# resultar diferentes en otros sistemas operativos al comprimir.
# Mejor asegurar que se compone solo de letras y números
clave = if Msip::Claverespaldo.count == 0
  "lalocura" # ;
else
  Msip::Claverespaldo.order(:id).last.clave
end

SOURCE_DIR = anexos
BASE_DEST_DIR = '/var/restovar1/anexos-por-anio'

min_year = Time.now.year
max_year = 0

puts "Iniciando copia por año ..."
puts "Criterio: Copiar solo si no existe o si el origen es más grande."


l=Dir.glob(File.join(SOURCE_DIR, '**', '*'))
count = 0
lastper = -1
l.each do |file|
  #puts "OJO file=#{file}"
  next unless File.file?(file)

  begin
    stat_src = File.stat(file)
    #puts "OJO stat_src=#{stat_src}"
    creation_time = stat_src.mtime #rescue stat_src.ctime
    #puts "OJO creation_time=#{creation_time}"
    year = creation_time.year
    #puts "OJO year=#{year}"

    if year < min_year
      min_year = year
    end
    if year > max_year
      max_year = year
    end

    dest_folder = File.join(BASE_DEST_DIR, "#{year}")
    #puts "OJO dest_folder=#{dest_folder}"
    relative_path = file.sub("#{SOURCE_DIR}/", '')
    #puts "OJO relative_path=#{relative_path}"
    nomarch = File.basename(relative_path)
    #puts "OJO nomarch=#{nomarch}"
    dest_file = File.join(dest_folder, nomarch)
    #puts "OJO dest_file=#{dest_file}"

    # Verificar condición de copia
    should_copy = false

    if !File.exist?(dest_file)
      # 1. El archivo no existe en el destino
      should_copy = true
    else
      # 2. El archivo existe, comparar tamaños
      size_src = stat_src.size
      size_dest = File.size(dest_file)
      
      if size_src > size_dest
        should_copy = true
        puts "Actualizando (Origen: #{size_src} > Destino: #{size_dest}): #{file}"
      end
    end

    #puts "OJO should_copy=#{should_copy}"
    if should_copy
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp(file, dest_file, preserve: true)
      puts "Copiado: #{file}"
    end
    count += 1
    per = count*100/l.length
    if per.round > lastper
      lastper=per.round
      puts "Processed: #{lastper}%"
    end
  end
rescue Errno::ENOENT
  puts "Error Errno::ENOENT"
  next
rescue NotImplementedError
  puts "Error NotImplementedError"
  next
end

puts "Copia finalizada."   

Dir.chdir(BASE_DEST_DIR)

year=min_year
while (year<=max_year) do
  puts "Comprimiendo año #{year}"
  salida = "#{nube}/Respaldos/anexos-#{year}.7z"
  ejecutar_en_shell(
    "doas",
    "7z",
    "u",
    "-p#{clave}",
    "-up1q0r2y2",
    salida,
    "#{year}/",
    "-x!heb412/Respaldos"
  )
  puts "Verificando archivo comprimido"
  ejecutar_en_shell(
    "doas",
    "7z",
    "t",
    "-p#{clave}",
    salida
  )
  year += 1
end

