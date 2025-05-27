# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Categoría y Desplazamiento
  class CategoriaDesplazamiento < ActiveRecord::Base
    self.table_name = "sivel2_sjr_categoria_desplazamiento"

    belongs_to :desplazamiento,
      class_name: "Sivel2Sjr::Desplazamiento",
      optional: false
    belongs_to :categoria,
      class_name: "Sivel2Gen::Categoria",
      optional: false
  end
end
