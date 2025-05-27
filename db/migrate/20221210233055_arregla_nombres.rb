# frozen_string_literal: true

class ArreglaNombres < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  SEQ = [
    ["anexo_seq", "sivel2_gen_anexo_caso_id_seq"],
    ["causaref_seq", "causaref_id_seq"],
    ["desplazamiento_seq", "sivel2_sjr_desplazamiento_id_seq"],
    ["instanciader_seq", "sivel2_sjr_instanciader_id_seq"],
    ["mecanismoder_seq", "sivel2_sjr_mecanismoder_id_seq"],
    ["motivoconsulta_seq", "sivel2_sjr_motivoconsulta_id_seq"],
    ["resagresion_seq", "sivel2_sjr_resagresion_id_seq"],
    ["respuesta_seq", "sivel2_sjr_respuesta_id_seq"],
  ]

  def up
    SEQ.each do |nomini, nomfin|
      renombrar_secuencia_pg(nomini, nomfin)
    end
    execute(<<~SQL.squish)
      DROP SEQUENCE IF EXISTS accion_seq;
      DROP SEQUENCE IF EXISTS proceso_seq;
      DROP TABLE IF EXISTS acto_errado;
      DROP TABLE IF EXISTS actosjr_errado;
      DROP TABLE IF EXISTS despacho;
      DROP TABLE IF EXISTS etapa;
      DROP SEQUENCE IF EXISTS despacho_seq;
      DROP SEQUENCE IF EXISTS etapa_seq;
    SQL
  end

  def down
    SEQ.reverse.each do |nomini, nomfin|
      renombrar_secuencia_pg(nomfin, nomini)
    end
  end
end
