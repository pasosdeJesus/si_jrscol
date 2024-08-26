

validaciones=[]
Msip::AnexosController.validar_existencia_archivo(validaciones)

validaciones[0][:cuerpo].each do |f| 
  if Sivel2Gen::AnexoCaso.where(anexo_id: f[0]).count > 0
    puts "Anexo a caso: #{Sivel2Gen::AnexoCaso.where(anexo_id: f[0]).take.caso_id}"
    Sivel2Gen::AnexoCaso.where(anexo_id: f[0]).delete_all
  elsif Sivel2Gen::AnexoVictima.where(anexo_id: f[0]).count > 0
    puts "Anexo a victima en caso #{Sivel2Gen::AnexoVictima.where(anexo_id: f[0]).take.victima.caso_id}"
    Sivel2Gen::AnexoVictima.where(anexo_id: f[0]).delete_all
  elsif Cor1440Gen::ActividadAnexo.where(anexo_id: f[0]).count > 0
    puts "Anexo a actividad #{Cor1440Gen::ActividadAnexo.where(anexo_id: f[0]).take.actividad_id}"
    Cor1440Gen::ActividadAnexo.where(anexo_id: f[0]).delete_all
  elsif Cor1440Gen::AnexoProyectofinanciero.where(anexo_id: f[0]).count > 0
    puts "Aneo a convenio financiado #{Cor1440Gen::AnexoProyectofinanciero.where(anexo_id: f[0])}"
    Cor1440Gen::AnexoProyectofinanciero.where(anexo_id: f[0]).delete_all
  end
  puts "Eliminando anexo #{f[0]}"
  Msip::Anexo.where(id: f[0]).delete_all
end

