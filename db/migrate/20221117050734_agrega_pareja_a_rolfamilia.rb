class AgregaParejaARolfamilia < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at)
        VALUES (18, 'PAREJA', null, '2022-11-16', null, '2022-11-16', '2022-11-16');
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM public.sivel2_sjr_rolfamilia WHERE id=18
    SQL
  end

end
