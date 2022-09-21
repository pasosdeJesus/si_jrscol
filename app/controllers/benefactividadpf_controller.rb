class BenefactividadpfController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Benefactividadpf
  def clase
    '::Benefactividadpf'
  end

  def atributos_index
    if Benefactividadpf
      arr = Benefactividadpf.column_names
      primeros =[
        "actividad_fecha",
        "actividad_oficina",
        "persona_tipodocumento", 
        "persona_numerodocumento",
        "persona_nombres", 
        "persona_apellidos",
        "persona_sexo", 
        "persona_anionac", 
        "persona_mesnac", 
        "persona_dianac", 
        "persona_actividad_edad",
        "persona_actividad_perfil",
        "actividad_municipio",
        "actividad_actividadesml",
        "actividad_id",
        "persona_caso_ids", 
        "persona_id"
      ]
      sobran = []
      acord1 = (arr-primeros-sobran)
      #acord2 = acord1.select {|c| c[-4..-1] == '_ids'}.sort
      #acord = acord2.map {|c| c.sub('_ids', '_enlace')}
      ret = primeros + acord1 - ["id"] 
      return ret
    end
  end

  def index
    contar_beneficiarios
    index_sip(Benefactividadpf.all)
  end

  def index_reordenar(c)
    c.reorder('LOWER(persona_nombres)')
  end

  def contar_beneficiarios
    @contarb_actividad = Cor1440Gen::Actividad.all
    @contarb_pf = Cor1440Gen::Proyectofinanciero.all
    @contarb_pfid = nil
    # Control de acceso
    #filtra_contarb_control_acceso

    # Parámetros
    @contarb_pfid = params[:filtro] && 
      params[:filtro][:proyectofinanciero_id] ?  
      params[:filtro][:proyectofinanciero_id].to_i : nil

    @contarb_oficinaid = params[:filtro] && 
      params[:filtro][:oficina_id] && params[:filtro][:oficina_id] != "" ?  
      params[:filtro][:oficina_id].to_i : nil

    if !params[:filtro] || !params[:filtro]['fechaini'] || 
        params[:filtro]['fechaini'] != ""
      if !params[:filtro] || !params[:filtro]['fechaini']
        @contarb_fechaini = Sip::FormatoFechaHelper.inicio_semestre_ant
      else
        @contarb_fechaini = Sip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro]['fechaini'])
      end
    end

    if !params[:filtro] || !params[:filtro]['fechafin'] || 
        params[:filtro]['fechafin'] != ""
      if !params[:filtro] || !params[:filtro]['fechafin']
        @contarb_fechafin = Sip::FormatoFechaHelper.fin_semestre_ant
      else
        @contarb_fechafin = Sip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro]['fechafin'])
      end
    end

    Benefactividadpf.crea_consulta(
      nil, @contarb_pfid, @contarb_oficinaid, @contarb_fechaini, 
      @contarb_fechafin
    )
  end

  def vistas_manejadas
    ['Benefactividadpf']
  end

  def index_otros_formatos_campoid
    return :persona_id
  end

  def self.vista_benefactividad_excel(
    plant, registros, narch, parsimp, extension, params)

      ruta = File.join(Rails.application.config.x.heb412_ruta, 
                       plant.ruta).to_s
      puts "ruta=#{ruta}"

      p = Axlsx::Package.new
      lt = p.workbook
      e = lt.styles

      estilo_base = e.add_style sz: 12
      estilo_titulo = e.add_style sz: 20
      estilo_encabezado = e.add_style sz: 12, b: true
      #, fg_color: 'FF0000', bg_color: '00FF00'

      lt.add_worksheet do |hoja|

        hoja.add_row ['Beneficiarios por actividad de marco lógico'], 
          height: 30, style: estilo_titulo
        hoja.add_row []
        hoja.add_row [
          'Fecha inicial', params['filtro']['fechaini'], 
          'Fecha final', params['filtro']['fechafin'] ], style: estilo_base
        hoja.add_row [
          'Oficina', params['filtro']['oficina_id'] == '' ? '' :
          Sip::Oficina.find(params['filtro']['oficina_id'].to_i).nombre,
          'Proyecto', params['filtro']['proyectofinanciero_id'] == '' ? '' :
          Cor1440Gen::Proyectofinanciero.find(
            params['filtro']['proyectofinanciero_id'].to_i).nombre,
        ], style: estilo_base
        hoja.add_row []
        l = [
          'Fecha Actividad',
          'Oficina Actividad',
          'Tipo de documento', 
          'Número de documento',
          'Nombres', 
          'Apellidos', 
          'Sexo', 
          'Dia Nacimiento',
          'Mes Nacimiento',
          'Año Nacimiento',
          'Edad en Act.',
          'Perfil Beneficiario',
          'Municipio Actividad',
          'Actividades de Marco Lógico'
        ]
        #caml1 = Benefactividadpf.columns.map(&:name)[5..-2]
        #caml2 = caml1.select {|c| c[-4..-1] == '_ids'}.sort
        #caml = caml2.map {|c| c.sub('_ids', '')}
        #l += caml
        l +=  [
          'Id. Actividad',
          'Id. Caso asociado al beneficiario',
          'Id. Beneficiario'
        ]

        hoja.merge_cells('A1:R1')

        hoja.add_row l, style: [estilo_encabezado] * l.length
        registros.order('UPPER(persona_nombres), UPPER(persona_apellidos), persona_id').each do |baml|
          l = [
            baml['actividad_fecha'].to_s,
            baml['actividad_oficina'],
            baml['persona_tipodocumento'],
            baml['persona_numerodocumento'],
            baml['persona_nombres'],
            baml['persona_apellidos'],
            baml['persona_sexo'],
            baml['persona_dianac'],
            baml['persona_mesnac'],
            baml['persona_anionac'],
            baml['persona_actividad_edad'],
            baml['persona_actividad_perfil'],
            baml['actividad_municipio'],
            baml['actividad_actividadesml']
          ]
          #caml.each do |c|
          #  l << baml[c]
          #end
          l << baml['actividad_id']
          l << baml['persona_caso_ids']
          l << baml['persona_id']
          hoja.add_row l, style: estilo_base
        end
        hoja.column_widths 20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
        ultf = 0
        hoja.rows.last.tap do |row|
          ultf = row.row_index
        end
        if ultf>0
          l = [nil]*14
          fs = hoja.add_row l
          lc = 'O'
          #caml.each do |c|
          #  fs.add_cell("=SUM(#{lc}7:#{lc}#{ultf})")
          #  lc = PlantillaHelper.sigcol(lc)
          #end
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
    case plant.vista
    when 'Benefactividadpf'
      r = self.vista_benefactividad_excel(
        plant, registros, narch, parsimp, extension, params)
      return r
    else
      r = registros
    end
    return r
  end

end
