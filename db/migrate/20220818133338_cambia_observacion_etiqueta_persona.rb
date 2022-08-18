class CambiaObservacionEtiquetaPersona < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, '; ', E'\n');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Nombres:', '* Nombres:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Apellidos:', '* Apellidos:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Tipo doc.:', '* Tipo doc.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Número de doc.:', '* Número de doc.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Año nac.:', '* Año nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Mes nac.:', '* Mes nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Dia nac.:', '* Dia nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Sexo nac.:', '* Sexo nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Pais nac.:', '* Pais nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Departamento nac.:', '* Departamento nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Muncipio nac.:', '* Municipio nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Centro poblado nac.:', '* Centro poblado nac.:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Nacional de:', '* Nacional de:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Fecha creación:', '* Fecha creación:');
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, 'Fecha actualización:', '* Fecha actualización:');
    SQL
  end

  def down
    execute <<-SQL
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, E'\n', '; ');
    SQL
  end
end
