#!/bin/sh
# Sugerido ejecutar  a diario (por ejemplo en /etc/daily.local)
# su -l miusuario -c "(cd /var/www/htdocs/sivel2_sjrcol; date ; bin/cron-diario.sh) >> /var/www/htdocs/sivel2_sjrcol/log/alertas.bitacora 2>&1" 

if (test -f .env) then {
  . .env
} fi;
bin/railsp runner -e production scripts/a_diario_runner.rb
