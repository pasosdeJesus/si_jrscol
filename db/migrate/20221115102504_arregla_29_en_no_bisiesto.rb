class Arregla29EnNoBisiesto < ActiveRecord::Migration[7.0]
  def up
    derr = Sip::Persona.where(dianac: 29).
      where(mesnac: 2).
      where('anionac%4<>0 AND anionac%1000<>0')
    puts "Se encontraron y cambiaron #{derr.count} personas con fecha de nacimiento 29.Feb de un año no bisiesto (#{derr.pluck(:id).join(', ')})"
    execute <<-SQL
      UPDATE sip_persona SET dianac=28 WHERE
        dianac=29 AND mesnac=2 AND anionac%4<>0 AND anionac%1000<>0 ;
    SQL
  end
  def down
  end
end
