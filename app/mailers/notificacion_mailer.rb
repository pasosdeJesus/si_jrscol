#require 'byebug'

class NotificacionMailer < ApplicationMailer

  def notificar_mantenimiento
    if !ENV['SMTP_MAQ']
      puts "No esta definida variable de ambiente SMTP_MAQ"
      exit 1
    end
    resultado = params[:resultado].to_s
    puts "OJO notificar_mantenimiento resultado=#{resultado}"
    @resultado = resultado
    return if !@resultado
    if params && params[:correo_depuracion]
      @para = params[:correo_depuracion]
    else
      admins = Usuario.where(rol: Ability::ROLADMIN).
        where(fechadeshabilitacion: nil)
      @para = admins.pluck(:email).sort.uniq
    end
    mail(to: @para, 
         subject: "[SI-JRSCOL] Notificación de mantenimiento a datos")
  end

end
