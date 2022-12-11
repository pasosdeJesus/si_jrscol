#!/usr/bin/env ruby



puts "Variables de ambiente"
puts "SMTP_MAQ=#{ENV.fetch('SMTP_MAQ')}"
puts "SMTP_PUERTO=#{ENV.fetch('SMTP_PUERTO')}"
puts "SMTP_DOMINIO=#{ENV.fetch('SMTP_DOMINIO')}"
puts "SMTP_USUARIO=#{ENV.fetch('SMTP_USUARIO')}"
puts "SMTP_CLAVE=#{'x'*(ENV.fetch('SMTP_CLAVE').length)}"

puts "Configuración de correo"
# https://makandracards.com/makandra/52335-actionmailer-how-to-send-a-test-mail-directly-from-the-console
mailer = ActionMailer::Base.new

puts "mailer.delivery_mthod: #{mailer.delivery_method}" # -> :smtp
puts "mailer.smtp_settings: #{mailer.smtp_settings}" # -> { address: "localhost", port: 25, domain:
# "localhost.localdomain", user_name: nil, password: nil, authentication: nil,
# enable_starttls_auto: true }

puts "Enviando correo de prueba mediante mailer.mail."
mailer.mail(from: ENV.fetch('SMTP_USUARIO'), to: 'vtamara@pasosdeJesus.org', 
            subject: 'correo de prueba', body: "Juan 8:32").deliver

puts "Enviando correo de prueba mediante NotificacionMailer."
begin
  NotificacionMailer.with(
    resultado: "Probando correo",
    correo_depuracion: 'vtamara@cinep.org.co'
  ).
  notificar_mantenimiento.deliver_now
rescue => e
  puts "** No se pudo enviar correo (#{e.to_s})"
end
