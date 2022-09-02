class Mejora < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE sip_tdocumento SET
      formatoregex='[0-9]*[A-Z]*',
      ayuda='Debe constar de digitos opcionalmente seguidos de letras mayúsculas. Por ejemplo 323948A' 
      WHERE id=11;
    SQL
  end
  def down
    execute <<-SQL
      UPDATE sip_tdocumento SET
      formatoregex='[0-9]*',
      ayuda='Debe constar solo de digitos. Por ejemplo 323948' 
      WHERE id=11;
    SQL
  end

end
