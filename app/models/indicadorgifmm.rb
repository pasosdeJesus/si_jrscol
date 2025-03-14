# Tabla básica Indicadores GIFMM
class Indicadorgifmm < ActiveRecord::Base
  include Msip::Basica

  belongs_to :sectorgifmm, foreign_key: 'sectorgifmm_id', 
    validate: true, class_name: 'Sectorgifmm', optional: false

  has_many :actividadpf, foreign_key: 'indicadorgifmm_id',
    class_name: 'Cor1440Gen::Actividadpf'
end
