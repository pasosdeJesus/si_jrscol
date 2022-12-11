require 'sivel2_gen/concerns/models/caso_solicitud'

module Sivel2Gen
  class CasoSolicitud < ActiveRecord::Base

    include Sivel2Gen::Concerns::Models::CasoSolicitud

    SER_ASESOR=1

    # Crea una solicitud predeterminada
    # Retorna mensaje de error si no lo logra o "" si lo logra
    def self.solicitar(remitente, codsol, caso_id, destinatarios)
      dsol = ""
      case codsol
      when SER_ASESOR
        dsol = "Ser asesor del caso #{caso_id}"
      end
      if dsol == ''
        return "codsol desconocido"
      end
      sol = Msip::Solicitud.create(
        usuario_id: remitente.id,
        fecha: Date.today,
        solicitud: dsol,
        estadosol_id: Msip::Solicitud::PENDIENTE
      );
      sol.usuarionotificar_ids = destinatarios.pluck(:id)
      sol.save
      Sivel2Gen::CasoSolicitud.create(
        solicitud_id: sol.id,
        caso_id: caso_id
      )
      return ""
    end

  end
end
