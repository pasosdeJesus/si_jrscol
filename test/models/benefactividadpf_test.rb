require 'test_helper'

class BenefactividadpfTest < ActiveSupport::TestCase

  PRUEBA_BENEFACTIVIDADPF = {
    persona_id: 1, 
    persona_nombre: "alejo", 
    edad_en_actividad: 23, 
    persona_identificacion: "1234", 
    persona_sexo: "M", 
    rangoedadac_nombre: "SIN INFORMACIÓN"
  }

  test "valido" do
    if ActiveRecord::Base.connection.data_source_exists?('Benefactividadpf')
      benefactividadpf = ::Benefactividadpf.new(
        PRUEBA_BENEFACTIVIDADPF)
      assert(benefactividadpf.valid?)
      benefactividadpf.destroy
    end
  end

end

