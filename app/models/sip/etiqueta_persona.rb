
module Sip
  class EtiquetaPersona < ActiveRecord::Base

    include Sip::Localizacion
    include Sip::FormatoFechaHelper

    self.table_name = 'sip_etiqueta_persona'

    belongs_to :persona, foreign_key: "persona_id", validate: true,
      class_name: 'Sip::Persona', inverse_of: :etiqueta_persona,
      optional: false
    belongs_to :etiqueta, foreign_key: "etiqueta_id", validate: true,
      class_name: 'Sip::Etiqueta', optional: false
    belongs_to :usuario, foreign_key: "usuario_id", validate: true, 
      optional: false

    campofecha_localizado :fecha

    validates_presence_of :fecha

  end # included

end
