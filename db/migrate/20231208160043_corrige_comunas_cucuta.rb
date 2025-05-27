# frozen_string_literal: true

class CorrigeComunasCucuta < ActiveRecord::Migration[7.0]
  def up
    [
      [9084, 11370], # Comuna 1
      [9088, 11371], # Comuna 2
      [9046, 11372], # Comuna 3
      [9051, 11373], # Comuna 4
      [9083, 11374], # Comuna 5
      [9031, 11375], # Comuna 6
      [9082, 11376], # Comuna 7
      [9076, 11377], # Comuna 8
      [9069, 11378], # Comuna 9
      [9070, 11379], # Comuna 10
    ].each do |p|
      next unless Msip::Centropoblado.where(id: p[0]).count == 1

      c = Msip::Centropoblado.find(p[0])
      u = Msip::Ubicacionpre.find(p[1])
      if u.centropoblado_id != c.id
        puts "No corresponden #{p[0]} con #{p[1]}"
        exit(1)
      end
      nc = Msip::Centropoblado.new(c.attributes.merge(
        nombre: c.nombre + "x_z",
        cplocal_cod: -c.cplocal_cod,
        id: nil,
      ))
      nc.save
      unless nc.valid?
        puts "nc no es valido en #{p}"
        exit(1)
      end
      nu = Msip::Ubicacionpre.new(u.attributes.merge(
        id: nil, centropoblado_id: nc.id,
      ))
      nu.poner_nombre_estandar
      nu.save
      unless nc.valid?
        puts "nu no es valido en #{p}"
        exit(1)
      end
      if nu.id.nil?
        puts "id en null en #{p}"
        exit(1)
      end
      execute(<<-SQL)
        UPDATE sivel2_sjr_desplazamiento SET expulsionubicacionpre_id=#{nu.id}
          WHERE expulsionubicacionpre_id=#{u.id};
        UPDATE sivel2_sjr_desplazamiento SET llegadaubicacionpre_id=#{nu.id}
          WHERE llegadaubicacionpre_id=#{u.id};
        UPDATE sivel2_sjr_desplazamiento SET destinoubicacionpre_id=#{nu.id}
          WHERE destinoubicacionpre_id=#{u.id};
        UPDATE sivel2_sjr_migracion SET salidaubicacionpre_id=#{nu.id}
          WHERE salidaubicacionpre_id=#{u.id};
        UPDATE sivel2_sjr_migracion SET llegadaubicacionpre_id=#{nu.id}
          WHERE llegadaubicacionpre_id=#{u.id};
        UPDATE sivel2_sjr_migracion SET destinoubicacionpre_id=#{nu.id}
          WHERE destinoubicacionpre_id=#{u.id};

      SQL
      u.delete
      execute(<<-SQL)
        UPDATE msip_ubicacionpre SET centropoblado_id=#{nc.id}
          WHERE centropoblado_id=#{c.id};
        UPDATE msip_ubicacion SET centropoblado_id=#{nc.id}
          WHERE centropoblado_id=#{c.id};
        UPDATE msip_persona SET centropoblado_id=#{nc.id}
          WHERE centropoblado_id=#{c.id};
      SQL
      c.delete
      nc.nombre = nc.nombre[0..-4]
      nc.cplocal_cod *= -1
      nc.save
      nu.centropoblado.reload
      nu.poner_nombre_estandar
      nu.save
    end
  end

  def down
  end
end
