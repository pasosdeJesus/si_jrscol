class OptimizaBenefactividad < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
       CREATE INDEX cor1440_gen_asistencia_persona_id_ind 
        ON cor1440_gen_asistencia (persona_id);
       CREATE INDEX cor1440_gen_asistencia_actividad_id_ind 
        ON cor1440_gen_asistencia (actividad_id);
       CREATE INDEX cor1440_gen_actividad_actividadpf_actividad_id_ind 
        ON cor1440_gen_actividad_actividadpf (actividad_id); 
       CREATE INDEX cor1440_gen_actividad_actividadpf_actividadpf_id_ind 
        ON cor1440_gen_actividad_actividadpf (actividadpf_id); 
       CREATE INDEX cor1440_gen_actividad_fecha_ind 
        ON cor1440_gen_actividad (fecha);
    SQL
  end

  def down
    execute <<-SQL
       DROP INDEX cor1440_gen_asistencia_persona_id_ind;
       DROP INDEX cor1440_gen_asistencia_actividad_id_ind;
       DROP INDEX cor1440_gen_actividad_actividadpf_actividad_id_ind;
       DROP INDEX cor1440_gen_actividad_actividadpf_actividadpf_id_ind;
       DROP INDEX cor1440_gen_actividad_fecha_ind;
    SQL
  end
 
end
