require 'sivel2_sjr/concerns/models/usuario'

class Usuario < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Usuario


  has_many :asesorhistorico,
    class_name: '::Asesorhistorico',
    validate: true, 
    foreign_key: :usuario_id

  has_many :etiqueta_persona,  
    foreign_key: 'usuario_id',
    validate: true,
    dependent: :destroy,
    class_name: 'Msip::EtiquetaPersona'

  def active_for_authentication?
    #logger.debug self.to_yaml
    # Si fecha de contrato es posterior a hoy no puede autenticarse
    hoy = Date.today
    r = super && (!fincontrato || fincontrato >= hoy)
    return r
  end
end

