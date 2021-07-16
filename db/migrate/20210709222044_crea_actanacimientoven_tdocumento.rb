class CreaActanacimientovenTdocumento < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      INSERT INTO public.sip_tdocumento (id, nombre, sigla, formatoregex, observaciones, ayuda, fechacreacion, fechadeshabilitacion, created_at, updated_at)
        VALUES (15, 'ACTA DE NACIMIENTO - VEN', 'AN', '[0-9]{4}[-][0-9]{1,2}[-][0-9]{1,2}[-]\\w*', null, 'Debe ser de la forma AÑO-MES-DIA-ID, por ejemplo 2018-10-21-1334 o 2017-3-2-AB33', '2021-07-09', null, '2021-07-09', '2021-07-09');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.sip_tdocumento WHERE id='15'
    SQL
  end
end
