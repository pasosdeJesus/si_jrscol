class ReservaDiezmillonesUbicacionespre < ActiveRecord::Migration[7.0]
  CAMPOS=[:id, :nombre, :pais_id, :departamento_id,
           :municipio_id, :centropoblado_id, :lugar,
           :sitio, :tsitio_id, :latitud, :longitud, 
           :created_at, :updated_at, :nombre_sin_pais]
  REFERENCIA=[
    ["cor1440_gen_actividad", "ubicacionpre_id"],
    ["sivel2_sjr_migracion", "destinoubicacionpre_id"],
    ["sivel2_sjr_migracion", "llegadaubicacionpre_id"],
    ["sivel2_sjr_migracion", "salidaubicacionpre_id"],
    ["actonino", "ubicacionpre_id"],
    ["sivel2_sjr_desplazamiento", "expulsionubicacionpre_id"],
    ["sivel2_sjr_desplazamiento", "llegadaubicacionpre_id"],
  ]



  def up
    Msip::Ubicacionpre.where('lugar IS NOT NULL').each do |u|
      r={}
      CAMPOS.each do |c|
        r[c]=u[c]
      end
      r[:id] += 10000000
      r[:nombre] += "2"
      nu = Msip::Ubicacionpre.create(r)
      if !nu.valid?
        debugger
      end
      REFERENCIA.each do |ref|
        sql="UPDATE #{ref[0]}
          SET #{ref[1]} = #{nu.id}
          WHERE #{ref[1]} = #{u.id};"
        puts sql
        Msip::Ubicacionpre.connection.execute sql
      end
      puts "eliminar #{u.id}"
      u.delete
      nu.nombre = nu.nombre[0..-1] # Quitar 2
      nu.save
    end
    Msip::Ubicacionpre.connection.execute <<-SQL
    SELECT setval('msip_ubicacionpre_id_seq', MAX(id)+1) FROM msip_ubicacionpre;
    SQL

  end
  def dow
  end
end
