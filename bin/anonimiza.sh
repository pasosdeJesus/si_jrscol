#!/bin/sh

# Sacar respaldo de sitio de producción --mejor rápido con COPY-- 
# Restaurarlo en sitio de desarrollo y después ejecutar este script
# para anonimizar la información y facilite pruebas

if (test ! -f .env) then {
  echo 'Falta archivo .env'
  exit 1;
} fi;
. .env

cmd="psql -h /var/www/var/run/postgresql -U $BD_USUARIO $BD_DES"
echo "$cmd"
psql -h /var/www/var/run/postgresql -U $BD_USUARIO $BD_DES <<EOF
  UPDATE sip_persona SET nombres='nombre'||id, apellidos='apellidos'||id;
  UPDATE usuario SET nombre='nombre'||id, descripcion='descripcion'||id,
    email='email'||id||'@ejemplo.org',last_sign_in_ip=null,
    current_sign_in_ip=null;

  UPDATE public.usuario SET
    nusuario='sjrcol',
    email='sjrcol@localhost.xyz',
    encrypted_password='$2a$10$qoo7Sh6ZoxplKPygeF2JDePwnpA1AhhkNUXkqOVy2YXK2jcs/BQU.',
    password='',
    fechacreacion='2014-01-12',
    fechadeshabilitacion=NULL,
    created_at='2013-12-24',
    updated_at='2013-12-24',
    rol=1
    WHERE id=1;
EOF

