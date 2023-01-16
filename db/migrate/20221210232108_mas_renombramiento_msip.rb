class MasRenombramientoMsip < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  def up
    if existe_índice_pg?('sip_persona_tdocumento_id_idx1')
      execute <<~SQL.squish
        DROP INDEX sip_persona_tdocumento_id_idx1;
      SQL
    end
    execute <<~SQL.squish
      CREATE OR REPLACE FUNCTION public.municipioubicacion(integer) 
        RETURNS character varying
        LANGUAGE sql
        AS $_$
          SELECT 
            (SELECT nombre FROM public.msip_pais 
              WHERE id=ubicacion.pais_id LIMIT 1) 
            || COALESCE((SELECT '/' 
               || nombre FROM public.msip_departamento 
               WHERE msip_departamento.id = ubicacion.departamento_id),'') 
            || COALESCE((SELECT '/' || nombre FROM public.msip_municipio 
               WHERE msip_municipio.id = ubicacion.municipio_id),'') 
            FROM public.msip_ubicacionpre AS ubicacion 
            WHERE ubicacion.id=$1;
        $_$;
    SQL
  end
  def down
    execute <<~SQL.squish
      CREATE OR REPLACE FUNCTION public.municipioubicacion(integer) 
        RETURNS character varying
        LANGUAGE sql
        AS $_$
          SELECT 
            (SELECT nombre FROM public.sip_pais 
              WHERE id=ubicacion.pais_id LIMIT 1) 
            || COALESCE((SELECT '/' 
               || nombre FROM public.sip_departamento 
               WHERE sip_departamento.id = ubicacion.departamento_id),'') 
            || COALESCE((SELECT '/' || nombre FROM public.sip_municipio 
               WHERE sip_municipio.id = ubicacion.municipio_id),'') 
            FROM public.msip_ubicacionpre AS ubicacion 
            WHERE ubicacion.id=$1;
        $_$;
    SQL

  end
end
