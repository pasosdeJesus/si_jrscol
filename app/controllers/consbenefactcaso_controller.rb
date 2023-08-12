#require 'jos19/concerns/controllers/consbenefactcaso_controller'

class ConsbenefactcasoController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Consbenefactcaso

  #include Jos19::Concerns::Controllers::ConsbenefactcasoController

  def clase
    '::Consbenefactcaso'
  end

  def atributos_index
    [:actividad_oficina_nombres,
     :persona_id,
     :persona_nombres,
     :persona_apellidos,
     :persona_tdocumento,
     :persona_numerodocumento,
     :persona_sexo,
     :persona_fechanac,
     :persona_edad_actual,
     :persona_paisnac,
     :persona_ultimoperfilorgsocial,
     :caso_id,
     :caso_fecharec,
     :caso_titular,
     :caso_telefono,
     :actividad_ids
    ]
  end

  def atributos_filtro_antestabla
    [
      'actividad_fechaini', 
      'actividad_fechafin', 
      'actividad_oficina_id',
      'actividadpf',
      'proyectofinanciero'
    ]
  end

  def index_reordenar(c)
    c.reorder([:persona_nombres, :persona_apellidos])
  end 


  def vistas_manejadas
    ['Consbenefactcaso']
  end

  def index
    ::Consbenefactcaso.refresca_consulta

    index_msip(::Consbenefactcaso.all)
  end

  def self.index_reordenar(registros)
    registros.reorder([:persona_id])
  end

  def self.vista_listado(plant, ids, modelo, narch, parsimp, extension,
                         campoid = :persona_id, 
                         params = nil, controlador = nil)
    registros = modelo.where(persona_id: ids)
    if respond_to?(:index_reordenar)
      registros = index_reordenar(registros)
    end
    case plant.id
    when 55
      registros = Consbenefactcaso::vista_reporte_excel(
        plant, registros, narch, parsimp, extension, params)

    end
    return registros
  end

  def self.valor_campo_compuesto(registro, campo)
    puts "registro=#{registro}"
    puts "campo=#{campo}"
  end


end
