# frozen_string_literal: true

class DiscapacidadEnAsistencia < ActiveRecord::Migration[7.0]
  def up
    add_column(
      :cor1440_gen_asistencia,
      :discapacidad,
      :boolean,
      default: false,
    )
    execute(<<-SQL)
      UPDATE cor1440_gen_asistencia SET discapacidad='t'
        WHERE persona_id IN (SELECT persona_id FROM sivel2_sjr_victimasjr AS vs
           JOIN sivel2_gen_victima AS v ON v.id=vs.victima_id#{" "}
          WHERE vs.discapacidad_id<>6);
    SQL
    narc = "/tmp/agregada_discapacidad.csv"
    puts "Actividades histórica en las que se puso discapaciad a alguna persona con base en información de casos que en archivo #{narc}"
    File.open(narc, "w") do |arc|
      arc.write("actividad_id, persona_id \n")
      reg = Cor1440Gen::Asistencia
        .where(discapacidad: true)
        .order([:actividad_id, :persona_id])
      reg.each do |asi|
        arc.write("#{asi.actividad_id}, #{asi.persona_id}\n")
      end
    end
  end

  def down
    remove_column(:cor1440_gen_asistencia, :discapacidad, :boolean)
  end
end
