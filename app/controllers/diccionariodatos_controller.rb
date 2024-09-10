class DiccionariodatosController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Diccionariodatos

  def clase
    '::Diccionariodatos'
  end

  # En orden de apilamiento
  MOTORES = Rails.configuration.railties_order.map {|m| 
    m.to_s == "main_app" ? "SI-JRSCOL" : m.to_s.split(':')[0]
  } - ["all"]

  TABLAS_NO_USADAS_EN_JRSCOL = [
    "mr519_gen_encuestapersona",
    "mr519_gen_encuestausuario",
    "mr519_gen_planencuesta",
    "msip_centropoblado_histvigencia",
    "msip_departamento_histvigencia",
    "msip_etiqueta_municipio",
    "msip_fuenteprensa",
    "msip_grupo",
    "msip_grupo_usuario",
    "msip_municipio_histvigencia",
    "msip_orgsocial_persona",
    "msip_pais_histvigencia",
    "msip_params_vistam",
    "msip_persona_trelacion",
    "msip_tipoorg",
    "msip_trelacion" ,
  ]


  def extraer_doc_de_clase_en_modulo(arch)
    pr = Prism.parse_file(arch)
    pr.attach_comments!
    cinst = pr.value.statements.body

    # Buscamos modulo
    m = 0
    while m < cinst.count && cinst[m].type != :module_node
      m += 1
    end
    if m >= cinst.count
      return "* No se encontró módulo en #{arch}"
    end

    # Extraemos documentación de la clase
    b = cinst[m].slice
    l = 1
    desc = ""
    while l < b.lines.count && !(b.lines[l] =~ /^[\s]*class/)
      if b.lines[l] =~ /^[\s]*# ?(.*)/
          desc += " " + $1
      end
      l += 1
    end
    return desc
  end


  def index
    authorize! :index, ::Diccionariodatos
    @registros = nil
    @motor_nombre = ""
    @motor_version = ""
    @motor_nombre_rayas = ""
    @motor_arch_desc = ""
    @motor_descripcion = ""
    @motor_tablas = []
    @motor_relaciones = []
    if params && params[:filtro] && params[:filtro][:motor] && 
        MOTORES.include?(params[:filtro][:motor])
      @motor_nombre = params[:filtro][:motor]
      @motor = @motor_nombre.constantize
      @motor_nombre_rayas = @motor_nombre.underscore

      # diccionario, llave será motor, valor será directorio del motor
      @motores_dir = {"SI-JRSCOL" => "."}
      Gem::Specification.find_all.each do |s|
        if MOTORES.include?(s.name.camelize)
          @motores_dir[s.name.camelize] = s.gem_dir
        end

        # Llenamos descripción y otros datos del motor elegido
        if s.name == @motor_nombre_rayas
          @motor_dir = s.gem_dir
          @motor_version = s.version.to_s
          @motor_arch_desc = File.join(
            @motor_dir, "/lib/", @motor_nombre_rayas + ".rb")
          if !File.exist?(@motor_arch_desc)
            raise "No existe archivo #{motor_arch_desc}"
          end
          pr = Prism.parse_file(@motor_arch_desc)
          pr.attach_comments!
          b = pr.value.slice
          l = 1
          @motor_descripcion = ""
          while l < b.lines.count && !(b.lines[l] =~ /^[\s]*module/)
            if b.lines[l] =~ /^[\s]*# ?(.*)/
              @motor_descripcion += " " + $1
            end
            l += 1
          end
        end
      end

      # Iteramos sobre las tablas del motor.
      @motor_tablas = []
      ActiveRecord::Base.connection.tables.select {|n|
        n.start_with?(@motor_nombre_rayas + "_") &&
          ActiveRecord::Base.connection.table_exists?(n) &&
          !TABLAS_NO_USADAS_EN_JRSCOL.include?(n)
      }.sort.each do |t|
        ncorto=t[(@motor_nombre_rayas.length+1)..-1]
        #if ncorto == 'campo'
        #  debugger
        #end
        postarch = "#{@motor_nombre_rayas}/#{ncorto}.rb"
        # Buscar descripción no vacía que esté más arriba en la pila de 
        # motores
        arch = ""
        clase = ""
        desc = ""
        llave = ""
        atributos = []
        registros = 0
        MOTORES.each do |m|
          parch = File.join(
            @motores_dir[m], "/app/models/#{postarch}"
          )
          if File.exist?(parch)
            arch = parch
            desc = extraer_doc_de_clase_en_modulo arch
            if desc != ""
              clase = (@motor.to_s+"::"+ncorto.camelize).constantize
              llave = clase.columns.map(&:name).include?("id") ? "id" : ""
              atributos = clase.columns.map(&:name) - ["id"]
              registros = clase.all.count
              break
            end
          end
        end
        if arch == ""
          desc = "* No existe archivo para #{postarch}"
        elsif desc == ""
          desc = "* No se encontró descripción para #{postarch}"
        end
        if desc.strip[0..7].downcase == "relación"
          @motor_relaciones << { 
            nombre: t, 
            descripcion: desc, 
            llave_primaria: llave,
            atributos: atributos,
            registros: registros
          }
        else
          @motor_tablas << { 
            nombre: t, 
            descripcion: desc, 
            llave_primaria: llave,
            atributos: atributos,
            registros: registros
          }
        end
      end
    end

    index_msip(@registros)
  end

  def vistas_manejadas
    ['Diccionariodatos']
  end

  def self.vista_consultabd_excel(
    plant, registros, narch, parsimp, extension, params
  )

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
      hoja.add_row ['Reporte Consultabd'], 
        height: 30, style: estilo_titulo
      hoja.add_row []
      hoja.add_row ['Consulta', params['filtro']['consultasql']], 
        style: [estilo_encabezado, estilo_base]
      hoja.add_row []

      l = Consultabd.columns.map {|r| r.name.to_s }
      numfilas = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numfilas)

      hoja.merge_cells("A1:#{colfin}1")

      hoja.add_row l, style: [estilo_encabezado] * numfilas
      registros.each do |reg|
        l2 = l.map {|c| reg[c]}
        hoja.add_row l2, style: estilo_base
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
    registros = ::Consultabd.all.where(numfila: ids)
    if plant.id == 57
      r = self.vista_consultabd_excel(
        plant, registros, narch, parsimp, extension, params
      )
      return r
    else
      if self.respond_to?(:index_reordenar)
        registros = self.index_reordenar(registros)
      end
      return registros
    end
  end

  def diccionariodatos_params
    params.require(:diccionariodatos).permit(
      :modulo
    )
  end


end
