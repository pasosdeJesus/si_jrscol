# Relación n:n entre detalle financiero y persona.
# Permite especificar una o más personas a un detalle financiero.
class DetallefinancieroPersona < ActiveRecord::Base

  belongs_to :detallefinanciero, 
    class_name: '::Detallefinanciero', 
    foreign_key: 'detallefinanciero_id'

  belongs_to :persona, 
    class_name: 'Msip::Persona', 
    foreign_key: 'persona_id'

end
