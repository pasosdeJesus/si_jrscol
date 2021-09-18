class Benefactividadpf < ActiveRecord::Base
  include Sip::Modelo

  scope :filtro_persona_nombre, lambda { |d|
    where("unaccent(persona_nombre) ILIKE '%' || unaccent(?) || '%'", d)
  }

  scope :filtro_persona_identificacion, lambda { |iden|
    where("unaccent(persona_identificacion) ILIKE '%' || unaccent(?) || '%'", iden)
  }

  scope :filtro_persona_sexo, lambda { |sexo|
    where(persona_sexo: sexo)
  }

  scope :filtro_rangoedadac_nombre, lambda { |rac|
    where(rangoedadac_nombre: rac)
  }
  module ClassMethods


    def interpreta_ordenar_por(campo)
      critord = ""
      case campo.to_s
      when /^fechadesc/
        critord = "conscaso.fecha desc"
      when /^fecha/
        critord = "conscaso.fecha asc"
      when /^ubicaciondesc/
        critord = "conscaso.ubicaciones desc"
      when /^ubicacion/
        critord = "conscaso.ubicaciones asc"
      when /^codigodesc/
        critord = "conscaso.caso_id desc"
      when /^codigo/
        critord = "conscaso.caso_id asc"
      else
        raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
      end
      critord += ", conscaso.caso_id"
      return critord
    end

  end # module ClassMethods
end
