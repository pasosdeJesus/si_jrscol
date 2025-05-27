# frozen_string_literal: true

# Saca copia de respaldo de volcado de base, anexos y nube
# La deja en carpeta Respaldos de la nube
# Para el cifrado y compresión usa 7z
# Como clave de cifrado usa la que tenga mayor id de la tabla
# msip_claverespaldo

d = Date.today.day

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

unless ENV["MSIP_RUTA_VOLCADOS"]
  puts "Falta variable de entorno MSIP_RUTA_VOLCADOS"
  exit 1
end
volcados = ENV["MSIP_RUTA_VOLCADOS"]

# El más reciente
volcados = Dir.glob("#{volcados}/*sql").max_by { |f| File.mtime(f) }
puts volcados

# https://stackoverflow.com/questions/690151/getting-output-of-system-calls-in-ruby
def ejecutar_en_shelll(*cmd)
  stdout, stderr, status = Open3.capture3(*cmd)
  status.success? && stdout.slice!(0..-(1 + $/.size)) # strip trailing eol
  puts stdout
  puts stderr
  puts status
rescue
end

# sql="/var/www/htdocs/sivel2_sjrcol/archivos/bd"
# anexos="/var/www/htdocs/sivel2_sjrcol/archivos/anexos"
# "/var/www/htdocs/sivel2_sjrcol/public/heb412"

salida = "#{nube}/Respaldos/si_jrscol-#{d}.7z"
# Ojo mejor que la clave no tenga caracteres por escapar que podrían
# resultar diferentes en otros sistemas operativos al comprimir.
# Mejor asegurar que se compone solo de letras y números
clave = if Msip::Claverespaldo.count == 0
  "lalocura" # ;
else
  Msip::Claverespaldo.order(:id).last.clave
end

orden = "doas 7z a -p#{clave} #{salida} #{volcados} #{anexos} #{nube} '-x!heb412/Respaldos'"
puts "Ejecutando #{orden}"

puts "Eliminando #{salida}"
ejecutar_en_shelll("doas", "rm", "-f", salida)
# puts "Comprimiendo en #{salida}"
ejecutar_en_shelll(
  "doas",
  "7z",
  "a",
  "-p#{clave}",
  salida,
  volcados,
  anexos,
  nube,
  "-x!heb412/Respaldos",
)
# puts "Comprimiendo menos en #{salida}"
# ejecutar_en_shelll('doas', '7z', 'a', "-p#{clave}", salida, nube, "-x!heb412/Respaldos")
