class CambiaObservacionEtiquetaPersona < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, ';', E'\n');
    SQL
  end

  def down
    execute <<-SQL
      UPDATE sip_etiqueta_persona 
        SET observaciones = replace(observaciones, E'\n', ';');
    SQL
  end
end
