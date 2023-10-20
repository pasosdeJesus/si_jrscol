require 'sivel2_gen/concerns/models/categoria'

class Sivel2Gen::Categoria < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Categoria


  has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
    through: :acto
  has_many :casosjr, foreign_key: "categoriaref", validate: true,
    class_name: 'Sivel2Sjr::Casosjr'

  has_and_belongs_to_many :desplazamiento, 
    class_name: 'Sivel2Sjr::Desplazamiento',
    foreign_key: :categoria_id, 
    association_foreign_key: "desplazamiento_id",
    join_table: 'sivel2_sjr_categoria_desplazamiento'

  has_many :causaRefugio, 
    class_name: 'Sivel2Sjr::Migracion',
    foreign_key: :causaRefugio_id

  scope :filtro_nombre_res1612, lambda {|n|
    where("unaccent(sivel2_gen_categoria.nombre_res1612) ILIKE '%' || unaccent(?) || '%'", n)
  }

end

