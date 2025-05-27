# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Etiqueta y Usuario. Pone etiquetas a un usuario.
  class EtiquetaUsuario < ActiveRecord::Base
    self.table_name = "sivel2_sjr_etiqueta_usuario"

    belongs_to :etiqueta,
      class_name: "Msip::Etiqueta",
      validate: true,
      optional: false
    belongs_to :usuario,
      class_name: "Usuario",
      validate: true,
      optional: false
  end
end
