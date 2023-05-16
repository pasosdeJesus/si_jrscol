require 'cor1440_gen/concerns/models/actividadpf'

module Cor1440Gen
  class Actividadpf < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Actividadpf

    validates :presupuesto, comparison: { greater_than_or_equal_to: 0 }

    belongs_to :indicadorgifmm, foreign_key: 'indicadorgifmm_id',
      optional: true, 
      class_name: 'Indicadorgifmm'
    
    def presenta_detallefinanciero_pfacpf
      pf = Cor1440Gen::Proyectofinanciero.find(proyectofinanciero_id).nombre
      "#{pf} - #{titulo}"
    end
    
    def presenta_detallefinanciero_pfacpf_abrev
      pf = Cor1440Gen::Proyectofinanciero.find(proyectofinanciero_id).nombre
      if pf.length > 6
        pf = pf[..5] + "..." 
      end
      return "#{pf} - #{titulo}"
    end
    
    scope :filtro_actividadtipo_id, lambda { |t|
        where(actividadtipo_id: t)
    }
  end
end
