class OptimizaConteoPersonas < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE INDEX sivel2_sjr_victimasjr_id_regimensalud_ind ON 
        sivel2_sjr_victimasjr (id_regimensalud); 
      CREATE INDEX sivel2_sjr_victimasjr_id_estadocivil_ind ON
        sivel2_sjr_victimasjr (id_estadocivil);
      CREATE INDEX sivel2_sjr_victimasjr_id_escolaridad_ind ON
        sivel2_sjr_victimasjr (id_escolaridad);
      CREATE INDEX sivel2_sjr_victimasjr_id_actividadoficio_ind ON
        sivel2_sjr_victimasjr (id_actividadoficio);
      CREATE INDEX sivel2_sjr_victimasjr_fechadesagregacion_ind ON
        sivel2_sjr_victimasjr (fechadesagregacion);
      CREATE INDEX sivel2_sjr_victimasjr_cabezafamilia_ind ON
        sivel2_sjr_victimasjr (cabezafamilia);
      CREATE INDEX sivel2_sjr_casosjr_fecharec_ind ON
        sivel2_sjr_casosjr (fecharec);
      CREATE INDEX sivel2_sjr_casosjr_mes_fecharec_ind ON
        sivel2_sjr_casosjr ((((date_part('year'::text, (fecharec)::timestamp without time zone))::text || '-'::text) || lpad((date_part('month'::text, (fecharec)::timestamp without time zone))::text, 2, '0'::text)));

      CREATE INDEX sivel2_gen_actividadoficio_nombre_ind ON
        sivel2_gen_actividadoficio (nombre);

    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX sivel2_sjr_victimasjr_id_regimensalud_ind;
      DROP INDEX sivel2_sjr_victimasjr_id_estadocivil_ind;
      DROP INDEX sivel2_sjr_victimasjr_id_escolaridad_ind;
      DROP INDEX sivel2_sjr_victimasjr_id_actividadoficio_ind;
      DROP INDEX sivel2_sjr_victimasjr_fechadesagregacion_ind;
      DROP INDEX sivel2_sjr_victimasjr_cabezafamilia_ind;
      DROP INDEX sivel2_sjr_casosjr_fecharec_ind;
      DROP INDEX sivel2_sjr_casosjr_mes_fecharec_ind;
    SQL
  end
end
