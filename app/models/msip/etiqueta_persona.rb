
module Msip
  class EtiquetaPersona < ActiveRecord::Base

    include Msip::Localizacion
    include Msip::FormatoFechaHelper

    self.table_name = 'msip_etiqueta_persona'

    belongs_to :persona, foreign_key: "persona_id", validate: false,
      class_name: 'Msip::Persona', inverse_of: :etiqueta_persona,
      optional: false
    belongs_to :etiqueta, foreign_key: "etiqueta_id", validate: false,
      class_name: 'Msip::Etiqueta', optional: false
    belongs_to :usuario, foreign_key: "usuario_id", validate: false, 
      optional: false

    campofecha_localizado :fecha

    validates_presence_of :fecha

  end # included

end
