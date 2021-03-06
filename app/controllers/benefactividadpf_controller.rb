class BenefactividadpfController < Heb412Gen::ModelosController

  
  load_and_authorize_resource class: ::Benefactividadpf
  def clase
    '::Benefactividadpf'
  end

  def atributos_index
    if Benefactividadpf
      arr = Benefactividadpf.column_names
      primeros =["persona_id", "persona_nombre", "persona_identificacion", 
                 "persona_sexo", "edad_en_actividad", "rangoedadac_nombre"]
      acord = (arr-primeros).sort
      primeros + acord - ["id"] 
    end
  end

  def index
    contar_beneficiarios
    index_sip(Benefactividadpf.all)
  end

  def index_reordenar(c)
    c.reorder('LOWER(persona_nombre)')
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
        l = ['Persona', 'Nombre', 'Identificación', 'Sexo', 
             'Edad en actividad', 'Rango de edad']
        caml = Benefactividadpf.columns.map(&:name)[5..-2].sort
        l += caml

        hoja.merge_cells('A1:F1')

        hoja.add_row l, style: [estilo_encabezado] * (7+caml.length)
        registros.order('UPPER(persona_nombre)').each do |baml|
          l = [baml['persona_id'],
               baml['persona_nombre'],
               baml['persona_identificacion'],
               baml['persona_sexo'],
               baml['edad_en_actividad'],
               baml['rangoedadac_nombre']
          ]
          caml.each do |c|
            l << baml[c]
          end
          hoja.add_row l, style: estilo_base
        end
        hoja.column_widths 20,20,20,20,20,20,20
        ultf = 0
        hoja.rows.last.tap do |row|
          ultf = row.row_index
        end
        if ultf>0
          l = [nil]*6
          fs = hoja.add_row l
          lc = 'G'
          caml.each do |c|
            fs.add_cell("=SUM(#{lc}7:#{lc}#{ultf})")
            lc = PlantillaHelper.sigcol(lc)
          end
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
