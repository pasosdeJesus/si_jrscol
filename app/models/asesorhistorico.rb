# Relación n:n entre Casosjr y usuario.
# Histórico de asesores de un caso.
class Asesorhistorico < ActiveRecord::Base

  include Msip::Localizacion
  include Msip::FormatoFechaHelper

  belongs_to :casosjr,
    foreign_key: 'casosjr_id',
    validate: true,
    class_name: 'Sivel2Sjr::Casosjr', optional: false
  belongs_to :usuario,
    foreign_key: 'usuario_id',
    validate: true,
    class_name: '::Usuario', optional: false
  belongs_to :oficina,
    foreign_key: 'oficina_id',
    validate: true,
    class_name: 'Msip::Oficina', optional: true


  campofecha_localizado :fechainicio
  campofecha_localizado :fechafin

  validates :fechainicio, comparison: { greater_than: Date.new(2000,1,1) }
  validates :fechafin, comparison: { greater_than_or_equal_to: :fechainicio }

end
