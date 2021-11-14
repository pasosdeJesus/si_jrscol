require 'test_helper'

class DeclaracionruvTest < ActiveSupport::TestCase

  PRUEBA_CONSGIFMM = {
    actividad_id: 852, 
    proyectofinanciero_id: 187, 
    actividadpf_id: 255,
    unidadayuda_id: 9,
    cantidad: 1,
    valorunitario: nil,
    valortotal: 20000,
    mecanismodeentrega_id: 3,
    modalidadentrega_id: 2,
    tipotransferencia_id: 2,
    frecuenciaentrega_id: 4,
    numeromeses: 3,
    numeroasistencia: 1,
    persona_ids: [],
    actividad_objetivo: "sss",
    fecha: "2020-07-12",
    conveniofinanciado_nombre: "PRM 2",
    actividadmarcologico_nombre: "aaa"
  }

  test "consulta gifmm  válida" do
    consgifmm_cols = ActiveRecord::Base.connection.execute(Consgifmm.consulta).nfields
    assert(consgifmm_cols > 0)
  end

end
