class SinExteriorMigracion < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :sivel2_sjr_migracion, :sip_clase, column: :salida_clase_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_municipio, column: :salida_municipio_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_departamento, column: :salida_departamento_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_pais, column: :salida_pais_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_clase, column: :llegada_clase_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_municipio, column: :llegada_municipio_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_departamento, column: :llegada_departamento_id_porborrar
    remove_foreign_key :sivel2_sjr_migracion, :sip_pais, column: :llegada_pais_id_porborrar
  end

  def down
    add_foreign_key :sivel2_sjr_migracion, :sip_clase, column: :salida_clase_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_municipio, column: :salida_municipio_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_departamento, column: :salida_departamento_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_pais, column: :salida_pais_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_clase, column: :llegada_clase_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_municipio, column: :llegada_municipio_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_departamento, column: :llegada_departamento_id_porborrar
    add_foreign_key :sivel2_sjr_migracion, :sip_pais, column: :llegada_pais_id_porborrar
  end
end
