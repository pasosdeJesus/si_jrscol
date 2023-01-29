class ConsgifmmController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Consgifmm

  def clase
    '::Consgifmm'
  end

  def atributos_index
    [
      :actividad_id,
      :fecha,
      :objetivo,
      :conveniofinanciado_nombre,
      :actividadmarcologico_nombre,
      :socio_principal,
      :tipo_implementacion,
      :socio_implementador,
      :departamento_gifmm,
      :municipio_gifmm,
      :mes,
      :estado,
      :parte_rmrp,
      :sector_gifmm,
      :indicador_gifmm,
      :beneficiarios_cuenta_y_enlaces,
      :beneficiarios_nuevos_mes_cuenta_y_enlaces,
    ]
  end

  def index_reordenar(c)
    #aapf = Cor1440Gen::ActividadActividadpf.where(actividad_id: 
    #                                              c.pluck(:actividad_id))
    #apf= Cor1440Gen::Actividadpf.where(id: aapf.pluck(:actividadpf_id))


    #@actipos = Cor1440Gen::Actividadtipo.where(
    #  id: apf.pluck(:actividadtipo_id)).pluck(:id, :nombre)
    c.reorder([:fecha, :actividad_id])
  end 

  def vistas_manejadas
    ['Consgifmm']
  end

  # Genera conteo por caso/beneficiario y tipo de actividad de convenio
  # #caso #act fechaact nom ap id gen edadfact rangoedad_fact etnia tipoac1 tipoac2 tipoac3 tipoac4 ... oficina asesoract 
  #                 EDADES HOMBRES            EDADES MUJERES                    
  #                                 0-5 6-12  13-17 18-26 27-59 +60 0-5 6-12  13-17 18-26 27-59 +60         
  def index
    if params.nil? || params[:filtro].nil?
      fant = Date.today - 30
      params[:filtro] = {}
      params[:filtro][:busfechaini] = fant.to_s
    end
    ::Consgifmm.refresca_consulta
    index_msip(::Consgifmm.all)
  end

  def self.valor_campo_compuesto(registro, campo)
    p = campo.split('.')
    if Mr519Gen::Formulario.where(nombreinterno: p[0]).count == 0
      return "No se encontró formulario con nombreinterno #{p[0]}"
    end
    f = Mr519Gen::Formulario.where(nombreinterno: p[0]).take

    rf = registro.actividad.respuestafor.where(
      formulario_id: f.id)
    if rf.count == 0
      return "" #No se encontró respuesta a formulario en cactividad
    elsif rf.count > 1
      return "Hay #{rf.count} respuestas al formulario #{f.id}"
    end
    rf = rf.take

    if p[1] == 'fecha_ultimaedicion'
      return rf.fechacambio
    end

    if f.campo.where(nombreinterno: p[1]).count == 0
      return "En formulario #{f.id} no se encontró campo con nombre interno #{p[2]}"
    end
    campo = f.campo.where(nombreinterno: p[1]).take
    op = []
    ope = nil
    if campo.tipo == 
        Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
      op = campo.opcioncs
      if p.count > 2 # Solicitud tiene opcion
        if op.where(valor: p[2]).count == 0
          return "En formulario #{f.id}, el campo con nombre interno #{p[1]} no tiene una opción con valor #{p[2]}"
        elsif op.where(valor: p[2]).count > 1
          return "En formulario #{f.id}, el campo con nombre interno #{p[1]} tiene más de una opción con valor #{p[2]}"
        end
        ope = op.where(valor: p[2]).take
      end
    end
    if rf.valorcampo.where(campo_id: campo.id).count == 0
      return "En respuesta a formulario #{rf.id} no se encontró valor para el campo #{campo.id}"
    end

    vc = rf.valorcampo.where(campo_id: campo.id).take
    if !ope.nil?
      return vc.valorjson.include?(ope.id.to_s) ? 1 : 0
    end
    if campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
      cop = vc.valorjson.select{|i| i != ''}.map {|idop|
        ope = Mr519Gen::Opcioncs.where(id: idop.to_i)
        ope.count == 0  ?  "No hay opcion con id #{idop}" :
          ope.take.nombre
      }
      return cop.join(". ")
    end

    vc.presenta_valor(false)
  end


  def self.vista_consgifmm_excel(
    plant, registros, narch, parsimp, extension, params)

    ruta = File.join(Rails.application.config.x.heb412_ruta, 
                     plant.ruta).to_s

    p = Axlsx::Package.new
    lt = p.workbook
    e = lt.styles

    estilo_base = e.add_style sz: 12
    estilo_titulo = e.add_style sz: 20
    estilo_encabezado = e.add_style sz: 12, b: true
    #, fg_color: 'FF0000', bg_color: '00FF00'

    lt.add_worksheet do |hoja|
      hoja.add_row ['Reporte GIFMM'], 
        height: 30, style: estilo_titulo
      hoja.add_row []
      hoja.add_row [
        'Fecha inicial', params['filtro']['busfechaini'], 
        'Fecha final', params['filtro']['busfechafin'] ], style: estilo_base
      idpf = (!params['filtro'] || 
              !params['filtro']['busconveniofinanciado_nombre'] || 
              params['filtro']['busconveniofinanciado_nombre'] == ''
             ) ? nil : params['filtro']['busconveniofinanciado_nombre']
      idaml = (!params['filtro'] || 
              !params['filtro']['busactividadmarcologico_nombre'] || 
              params['filtro']['busactividadmarcologico_nombre'] == ''
              ) ? nil : params['filtro']['busactividadmarcologico_nombre']

      npf = idpf.nil? ? '' :
        Cor1440Gen::Proyectofinanciero.where(id: idpf).
        pluck(:nombre).join('; ')
      naml = idaml.nil? ? '' :
        Cor1440Gen::Actividadpf.where(id: idaml).
        pluck(:titulo).join('; ')

      hoja.add_row ['Convenio financiero', npf, 'Actividad de marco lógico', naml], style: estilo_base
      hoja.add_row []
      l = [
        'Oficina',
        'Id Actividad',
        'Convenio Financiado', 
        'Socio Principal', 
        'Tipo de implementación',
        'Socio implementador',
        'Departamento', 
        'Municipio', 
        'Mes',
        'Sector GIFMM',
        'Indicador GIFMM',
        'Código del indicador',
        'Actividad de marco lógico',
        'Nombre de la actividad',
        'Descripción de la actividad (Objetivo)',
        'Actividad del RMRP',
        'Actividad para caminantes',
        'Actividad en apoyo en ETPV',
        'Tipo de apoyo al ETPV',
        'Tipo',
        'Cantidad',
        'Modalidad',
        'Monto en USD (OJO COP)',
        'Mecanismo de entrega',
        'Cantidad de output: # beneficiarios indirectos',
        'Total beneficiarios alcanzados en el mes',
        'Beneficiarios nuevos en el mes',
        'Con vocación de permanencias',
        'En tránsitos',
        'Comunidad de acogidas',
        'Pendulares',
        'Colombianos retornados',
        'Niñas y adolescentes <17',
        'Mujeres adultas >= 18',
        'Niños y adolescentes <17',
        'Hombres adultos >= 18',
        'Otros no binarios <17',
        'Otros no binarios >= 18',
        'LGBTI+',
        'Con discapacidades',
        'Afrodescendientes',
        'Indígenas',
        'Otra comunidad étnica',
        '*Nuevos Sin sexo <= 17 o sin rango de edad',
        '*Nuevas Niñas y adolescentes <17',
        '*Nuevas Niños y adolescentes <17',
        '*Nuevos Sin sexo >= 18 o sin rango de edad',
        '*Nuevas Mujeres adultas >= 18',
        '*Nuevos Hombres adultos >= 18',
      ]
      numfilas = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numfilas)

      hoja.merge_cells("A1:#{colfin}1")

      hoja.add_row l, style: [estilo_encabezado] * numfilas
      
      registros.each do |reg|
        l = [
          reg.oficina.to_s,
          reg.actividad_id,
          reg['conveniofinanciado_nombre'],
          reg.socio_principal,
          reg.presenta('tipo_implementacion'),
          reg.presenta('socio_implementador'),
          reg['departamento_gifmm'],
          reg['municipio_gifmm'],
          reg.presenta('mes'),
          reg.sector_gifmm,
          reg.indicador_gifmm,
          '', # código del indicador
          reg['actividadmarcologico_nombre'],
          reg['actividad_nombre'].to_s,
          reg['actividad_objetivo'].to_s,
          reg.presenta('parte_rmrp'),
          '', #'Actividad para caminantes',
          '', #'Actividad en apoyo en ETPV',
          '', #'Tipo de apoyo al ETPV',
          '', #'Tipo',
          reg.detalleah_cantidad,
          reg.detalleah_modalidad,
          reg.detalleah_monto_por_persona,
          reg.detalleah_mecanismo_entrega,
          '', #'Cantidad de output: # beneficiarios indirectos'
          reg.beneficiarios_ids.split(",").count,
          reg.beneficiarios_nuevos_mes_ids.split(",").count,
          reg.beneficiarios_nuevos_vocacion_permanencia_ids.split(",").count,
          reg.beneficiarios_nuevos_en_transito_ids.split(",").count,
          reg.beneficiarios_nuevos_comunidades_de_acogida_ids.split(",").count,
          reg.beneficiarios_nuevos_pendulares_ids.split(",").count,
          reg.beneficiarios_nuevos_colombianos_retornados_ids.split(",").count,
          reg.beneficiarias_nuevas_ninas_adolescentes_y_se_ids.split(",").count + reg.beneficiarios_nuevos_sinsexo_menores_y_se_ids.split(",").count/2,
          reg.beneficiarias_nuevas_mujeres_adultas_ids.split(",").count + reg.beneficiarios_nuevos_sinsexo_adultos_ids.split(",").count,
          reg.beneficiarios_nuevos_ninos_adolescentes_y_se_ids.split(",").count + reg.beneficiarios_nuevos_sinsexo_menores_y_se_ids.split(",").count/2,
          reg.beneficiarios_nuevos_hombres_adultos_ids.split(",").count + reg.beneficiarios_nuevos_sinsexo_adultos_ids.split(",").count/2,
          0, # 'Otros no binarios <17',
          0, # 'Otros no binarios >= 18',
          reg.beneficiarios_nuevos_lgbti_ids.split(",").count,
          reg.beneficiarios_nuevos_con_discapacidad_ids.split(",").count,
          reg.beneficiarios_nuevos_afrodescendientes_ids.split(",").count,
          reg.beneficiarios_nuevos_indigenas_ids.split(",").count,
          reg.beneficiarios_nuevos_otra_etnia_ids.split(",").count,
          reg.beneficiarios_nuevos_sinsexo_menores_y_se_ids.split(",").count,
          reg.beneficiarias_nuevas_ninas_adolescentes_y_se_ids.split(",").count,
          reg.beneficiarios_nuevos_ninos_adolescentes_y_se_ids.split(",").count,
          reg.beneficiarios_nuevos_sinsexo_adultos_ids.split(",").count,
          reg.beneficiarias_nuevas_mujeres_adultas_ids.split(",").count,
          reg.beneficiarios_nuevos_hombres_adultos_ids.split(",").count,
        ]
        hoja.add_row l, style: estilo_base
      end
      anchos = [20] * numfilas
      hoja.column_widths(*anchos)
      ultf = 0
      hoja.rows.last.tap do |row|
        ultf = row.row_index
      end
      if ultf>0
        l = [nil] * numfilas
        hoja.add_row l
      end

    end

    n=File.join('/tmp', File.basename(narch + ".xlsx"))
    p.serialize n
    FileUtils.rm(narch + "#{extension}-0")

    return n
  end


  def self.vista_listado(plant, ids, modelo, narch, parsimp, extension,
                         campoid = :id, params)
    registros = modelo.where(campoid => ids)
    if plant.id == 51
      r = self.vista_consgifmm_excel(
        plant, registros, narch, parsimp, extension, params)
      return r
    else
      if self.respond_to?(:index_reordenar)
        registros = self.index_reordenar(registros)
      end
      return registros
    end
  end

end
