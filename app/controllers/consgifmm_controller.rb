class ConsgifmmController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Consgifmm

  def clase
    '::Consgifmm'
  end

  def atributos_index
    c = (@columnas.map {|c| c.to_sym}) & ([:actividad_id] + columnas_posibles)
    puts "OJO c=#{c}"
    return c
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

  def columnas_posibles
    [ :fecha,
      :actividad_objetivo,
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
      :beneficiarios_nuevos_mes_cuenta_y_enlaces
    ]
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
      params[:filtro][:columnas] = columnas_posibles
    end
    @columnas = [:actividad_id] | params[:filtro][:columnas]
    ::Consgifmm.refresca_consulta(@columnas)
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
        'Mes de atención',
        'Sector',
        'Indicador',
        'Actividad de marco lógico',
        'Nombre de la actividad',
        'Descripción de la actividad (Objetivo)',
        'Actividad del RMRP',
        'Actividad para caminantes',
        'Actividad en apoyo en ETPV',
        'Tipo de apoyo al ETPV',
        'Cantidad',
        'Modalidad',
        'Monto en USD',
        'Mecanismo de entrega',
        'Cantidad de output: # beneficiarios indirectos',
        'Total beneficiarios alcanzados en el mes',
        'Beneficiarios nuevos en el mes',
        'Con vocación de permanencia',
        'En tránsito',
        'Comunidad de acogidas',
        'Pendulares',
        'Colombianos/as retornados/as',
        'Víctimas',
        'Víctimas doble afectación',
        'Sin Perfil Poblacional',
        '0 a 5',
        '6 a 12',
        '13 a 17',
        '18 a 25',
        '26 a 59',
        '60 o más',
        '0 a 5',
        '6 a 12',
        '13 a 17',
        '18 a 25',
        '26 a 59',
        '60 o más',
        '0 a 5',
        '6 a 12',
        '13 a 17',
        '18 a 25',
        '26 a 59',
        '60 o más',
        'Con discapacidad',
        'Afrodescendientes',
        'Indígenas',
        'Otra comunidad étnica',
        '*Sin sexo 0 a 5',
        '*Sin sexo 6 a 12',
        '*Sin sexo 13 a 17',
        '*Sin sexo 18 a 25',
        '*Sin sexo 26 a 59',
        '*Sin sexo 60 o más',
        '*Mujeres sin edad',
        '*Hombres sin edad',
        '*Sin sexo y sin edad',
        '*Otro sexo y sin edad'
      ]
      numfilas = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numfilas)

      hoja.merge_cells("A1:#{colfin}1")

      l2 = ([''] * 33) + ['Mujeres'] + ([''] * 5) + ['Hombres'] + ([''] * 5) +
        ['Otro sexo'] + ([''] * 5)
      hoja.add_row l2, style: [estilo_encabezado] * numfilas
      hoja.merge_cells("AH6:AM6")
      hoja.merge_cells("AN6:AS6")
      hoja.merge_cells("AT6:AY6")

      hoja.add_row l, style: [estilo_encabezado] * numfilas
      
      registros.each do |reg|
        l = [
          reg.oficina.to_s,
          reg.actividad_id,
          reg['conveniofinanciado_nombre'],
          reg.presenta('socio_principal'),
          reg.presenta('tipo_implementacion'),
          reg.presenta('socio_implementador'),
          reg['departamento_gifmm'],
          reg['municipio_gifmm'],
          reg.presenta('mes'),
          reg.presenta('sector_gifmm'),
          reg.presenta('indicador_gifmm'),
          reg['actividadmarcologico_nombre'],
          reg['actividad_nombre'].to_s,
          reg['actividad_objetivo'].to_s,
          reg.presenta('parte_rmrp'),
          '', #'Actividad para caminantes',
          '', #'Actividad en apoyo en ETPV',
          '', #'Tipo de apoyo al ETPV',
          reg.presenta('detalleah_cantidad'),
          reg.presenta('detalleah_modalidad'),
          '', # Por ahora en blanco pues no definieron lo de la tabla con tasa de cambio reg.detalleah_monto_por_persona,
          reg.presenta('detalleah_mecanismo_entrega'),
          '', #'Cantidad de output: # beneficiarios indirectos'
          reg.presenta('beneficiarios_ids').split(",").count,
          reg.presenta('beneficiarios_nuevos_mes_ids').split(",").count,
          reg.presenta('beneficiarios_vocacion_permanencia_ids').split(",").count,
          reg.presenta('beneficiarios_en_transito_ids').split(",").count,
          reg.presenta('beneficiarios_comunidades_de_acogida_ids').split(",").count,
          reg.presenta('beneficiarios_pendulares_ids').split(",").count,
          reg.presenta('beneficiarios_colombianos_retornados_ids').split(",").count,
          reg.presenta('beneficiarios_victimas_ids').split(",").count,
          reg.presenta('beneficiarios_victimasdobleafectacion_ids').split(",").count,
          reg.presenta('beneficiarios_sinperfilpoblacional_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_0_5_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_6_12_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_13_17_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_18_25_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_26_59_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_60_o_mas_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_0_5_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_6_12_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_13_17_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_18_25_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_26_59_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_60_o_mas_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_0_5_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_6_12_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_13_17_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_18_25_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_26_59_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_60_o_mas_ids').split(",").count,
          reg.presenta('beneficiarios_con_discapacidad_ids').split(",").count,
          reg.presenta('beneficiarios_afrodescendientes_ids').split(",").count,
          reg.presenta('beneficiarios_indigenas_ids').split(",").count,
          reg.presenta('beneficiarios_otra_etnia_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_0_5_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_6_12_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_13_17_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_18_25_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_26_59_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_60_o_mas_ids').split(",").count,
          reg.presenta('beneficiarias_mujeres_sinedad_ids').split(",").count,
          reg.presenta('beneficiarios_hombres_sinedad_ids').split(",").count,
          reg.presenta('beneficiarios_sinsexo_sinedad_ids').split(",").count,
          reg.presenta('beneficiarios_otrosexo_sinedad_ids').split(",").count,
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
    ::ConsgifmmExp.refresca_consulta(nil, ids);
    registros = ::ConsgifmmExp.all.where(consgifmm_id: ids)
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
