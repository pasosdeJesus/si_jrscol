class MejoraDivisionpa < ActiveRecord::Migration[7.0]
  def up
    # Quitar paises duplicados
    [
      [76, 26, 1185], # Brasil
      [218, 63, 932], # Ecuador
      [591, 171, 647], # Panamá
      [604, 174, 1057], # Panamá
      [862, 248, 779], # Venezuela
    ].each do |dp|
      if Msip::Ubicacionpre.find(dp[1]).pais_id != dp[0] ||
        Msip::Ubicacionpre.find(dp[2]).pais_id != dp[0] 
        puts "Ubicacionpre no corresponde en pais #{dp[0]}"
        exit 1;
      end
      execute <<-SQL
        UPDATE sivel2_sjr_migracion SET salidaubicacionpre_id=#{dp[1]}
          WHERE salidaubicacionpre_id=#{dp[2]};
        UPDATE sivel2_sjr_desplazamiento SET expulsionubicacionpre_id=#{dp[1]}
          WHERE expulsionubicacionpre_id=#{dp[2]};
        UPDATE sivel2_sjr_desplazamiento SET llegadaubicacionpre_id=#{dp[1]}
          WHERE llegadaubicacionpre_id=#{dp[2]};
        UPDATE sivel2_sjr_desplazamiento SET destinoubicacionpre_id=#{dp[1]}
          WHERE destinoubicacionpre_id=#{dp[2]};
        DELETE FROM msip_ubicacionpre WHERE id=#{dp[2]};
      SQL
    end

    
    # para hacer la division pa como la de msip
    execute <<-SQL
      -- Centro poblado Cienga del Opon 13422 a Cienaga de Opon 14876
      UPDATE msip_ubicacionpre 
        SET centropoblado_id=14876
        WHERE centropoblado_id=13422;
      DELETE  FROM msip_ubicacionpre WHERE centropoblado_id=13422;
    SQL
    puts "OJO 2"
    execute <<-SQL
      UPDATE msip_persona SET centropoblado_id=14876
        WHERE centropoblado_id=13422;
      UPDATE msip_ubicacion SET centropoblado_id=14876
        WHERE centropoblado_id=13422;
      DELETE  FROM msip_centropoblado WHERE id = 13422;
    SQL
    puts "Quita duplicado"
    execute <<-SQL
      -- Quita duplicado
      UPDATE sivel2_sjr_desplazamiento SET expulsionubicacionpre_id=3234
          WHERE expulsionubicacionpre_id=12688;
      DELETE FROM msip_ubicacionpre WHERE id=12688;
    SQL

    # Comunas de Buenaventura erradamente agregadas como centros poblados
    # y con código de comunes
    [
      ['Comuna 02',2756,13423],
      ['Comuna 01',2755,13424],
      ['Comuna 03',2757,13425],
      ['Comuna 04',2758,13426],
      ['Comuna 05',2759,13427],
      ['Comuna 06',2760,13428],
      ['Comuna 07',2761,13429],
      ['Comuna 08',2762,13430],
      ['Comuna 09',2763,13432],
      ['Comuna 10',2764,13433],
      ['Comuna 11',2753,13434],
      ['Comuna 12',2754,13435]
    ].each do |com|
      nuid=com[1]+10000000
      execute <<-SQL
        INSERT INTO msip_ubicacionpre (id,nombre,pais_id,departamento_id,
          municipio_id, centropoblado_id, lugar, created_at, updated_at,
          nombre_sin_pais) VALUES 
          (#{nuid}, 
          '#{com[0]} / Buenaventura, Distrito Especial, Industrial, Portuario, Biodiverso y Ecoturístico  Buenaventura / Valle del Cauca / Colombia',
           170, 47, 86, 11771, '#{com[0]}', '2020-10-02', '2020-10-02',
           '#{com[0]} / Buenaventura / Buenaventura / Valle del Cauca');
  
        UPDATE sivel2_sjr_migracion SET salidaubicacionpre_id=#{nuid}
          WHERE salidaubicacionpre_id=#{com[1]};
        UPDATE sivel2_sjr_desplazamiento SET expulsionubicacionpre_id=#{nuid}
          WHERE expulsionubicacionpre_id=#{com[1]};

        UPDATE msip_ubicacionpre 
          SET centropoblado_id=11771,
          lugar=lugar || ' - #{com[0]}'
        WHERE centropoblado_id = #{com[2]};

        DELETE  FROM msip_ubicacionpre WHERE centropoblado_id = #{com[2]};

        UPDATE msip_persona SET centropoblado_id=11771 
          WHERE centropoblado_id=#{com[2]};

        UPDATE msip_ubicacion SET centropoblado_id=11771
          WHERE centropoblado_id=#{com[2]};

        DELETE  FROM msip_centropoblado WHERE id = #{com[2]};
      SQL
      # Quita duplicación de 11771 en ubicacionpre como dpa
      idsrep = Msip::Ubicacionpre.where(centropoblado_id: 11771).where(
        lugar: nil).pluck(:id).sort
      idsrep[1..-1].each do |ipb|
        execute <<-SQL
          UPDATE sivel2_sjr_migracion SET salidaubicacionpre_id=#{idsrep[0]}
            WHERE salidaubicacionpre_id=#{ipb};
          UPDATE sivel2_sjr_migracion SET llegadaubicacionpre_id=#{idsrep[0]}
            WHERE llegadaubicacionpre_id=#{ipb};
          UPDATE sivel2_sjr_migracion SET destinoubicacionpre_id=#{idsrep[0]}
            WHERE destinoubicacionpre_id=#{ipb};
          UPDATE sivel2_sjr_desplazamiento SET 
            expulsionubicacionpre_id=#{idsrep[0]}
            WHERE expulsionubicacionpre_id=#{ipb};
          UPDATE sivel2_sjr_desplazamiento SET 
            llegadaubicacionpre_id=#{idsrep[0]}
            WHERE llegadaubicacionpre_id=#{ipb};
          UPDATE sivel2_sjr_desplazamiento SET 
            destinoubicacionpre_id=#{idsrep[0]}
            WHERE destinoubicacionpre_id=#{ipb};
          DELETE FROM msip_ubicacionpre WHERE id=#{ipb};
        SQL
      end

    end

    execute <<-SQL
      INSERT INTO public.msip_centropoblado (id, nombre, municipio_id, 
        cplocal_cod, tcentropoblado_id, latitud, longitud, fechacreacion, 
        fechadeshabilitacion, created_at, updated_at, observaciones, 
        ultvigenciaini, ultvigenciafin, svgruta, svgcdx, svgcdy, 
        svgcdancho, svgcdalto, svgrotx, svgroty) VALUES (15403, 'La Catalina', 
        51, 46, 'CP', 2.355267831, -73.58026535, '2021-12-16', NULL, 
        '2021-12-16 00:00:00', '2021-12-16 00:00:00', 
        'Aparece en DIVIPOLA 2020', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
        NULL, NULL);
    SQL
  end
  def down
  end
end
