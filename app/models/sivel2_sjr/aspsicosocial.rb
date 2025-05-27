# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica asistencias psicosociales
  class Aspsicosocial < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_aspsicosocial"

    has_many :aspsicosocial_respuesta,
      class_name: "Sivel2Sjr::AspsicosocialRespuesta",
      validate: true,
      dependent: :destroy
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      through: :aspsicosocial_respuesta

    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
