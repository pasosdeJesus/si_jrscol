conexion = ActiveRecord::Base.connection();

# De motores
Msip::carga_semillas_sql(conexion, 'msip', :datos)
motor = ['sivel2_gen', 'cor1440_gen', nil]
motor.each do |m|
  puts "#{m} cambios"
  Msip::carga_semillas_sql(conexion, m, :cambios)
  puts "#{m} datos"
  Msip::carga_semillas_sql(conexion, m, :datos)
end

# Extrañamente borrar el search_path y falla el siguiente o
# las migraciones
conexion.execute('SET search_path TO "$user", public')

# Usuario inicial: sjrcol con clave sjrcol123
conexion.execute("INSERT INTO public.usuario
	(id, nusuario, email, encrypted_password, password,
  fechacreacion, created_at, updated_at, rol)
	VALUES (1, 'jrscol', 'jrscol@localhost.org',
  '$2a$10$1.QNKH7/3sFbf2akI66LG.rumGWmTJcGIUwWyN9Wblx0TCdb0VrY6',
	'', '2014-01-12', '2013-12-24', '2013-12-24', 1);")


