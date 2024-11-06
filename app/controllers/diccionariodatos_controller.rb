class DiccionariodatosController < ApplicationController

  load_and_authorize_resource class: ::Diccionariodatos

  # En orden de apilamiento
  MOTORES = Rails.configuration.railties_order.map {|m|
    m.to_s == "main_app" ? "SI-JRSCOL" : m.to_s.split(':')[0]
  } - ["all"]

  TABLAS_NO_USADAS_EN_JRSCOL = [
    "cor1440_gen_anexo_efecto",
    "cor1440_gen_desembolso",
    "cor1440_gen_efecto",
    "cor1440_gen_efecto_orgsocial",
    "cor1440_gen_efecto_respuestafor",
    "cor1440_gen_efecto_respuestafor",
    "cor1440_gen_formulario_mindicadorpf",
    "cor1440_gen_formulario_tipoindicador",
    "cor1440_gen_informe",
    "cor1440_gen_informeauditoria",
    "cor1440_gen_informefinanciero",
    "cor1440_gen_informenarrativo",
    "cor1440_gen_plantillahcm_proyectofinanciero",
    "heb412_gen_campohc",
    "heb412_gen_doc",
    "heb412_gen_plantilladoc",
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
    "sivel2_gen_antecedente" ,
    "sivel2_gen_antecedente_caso" ,
    "sivel2_gen_antecedente_combatiente" ,
    "sivel2_gen_antecedente_victima" ,
    "sivel2_gen_antecedente_victimacolectiva" ,
    "sivel2_gen_actocolectivo" ,
    "sivel2_gen_categoria_presponsable" ,
    "sivel2_gen_caso_contexto" ,
    "sivel2_gen_caso_etiqueta" ,
    "sivel2_gen_caso_fotra" ,
    "sivel2_gen_caso_frontera" ,
    "sivel2_gen_caso_fuenteprensa" ,
    "sivel2_gen_caso_region" ,
    "sivel2_gen_caso_respuestafor" ,
    "sivel2_gen_combatiente" ,
    "sivel2_gen_contexto" ,
    "sivel2_gen_contextovictima" ,
    "sivel2_gen_contextovictima_victima" ,
    "sivel2_gen_departamento_region" ,
    "sivel2_gen_etnia_victimacolectiva",
    "sivel2_gen_filiacion_victimacolectiva" ,
    "sivel2_gen_fotra" ,
    "sivel2_gen_frontera" ,
    "sivel2_gen_iglesia" ,
    "sivel2_gen_intervalo" ,
    "sivel2_gen_municipio_region" ,
    "sivel2_gen_observador_filtrodepartamento" ,
    "sivel2_gen_organizacion_victimacolectiva" ,
    "sivel2_gen_otraorga_victima" ,
    "sivel2_gen_pconsolidado" ,
    "sivel2_gen_profesion_victima" ,
    "sivel2_gen_profesion_victimacolectiva" ,
    "sivel2_gen_rangoedad_victimacolectiva" ,
    "sivel2_gen_region" ,
    "sivel2_gen_resagresion" ,
    "sivel2_gen_sectorsocial" ,
    "sivel2_gen_sectorsocial_victimacolectiva" ,
    "sivel2_gen_sectorsocialsec_victima" ,
    "sivel2_gen_victimacolectiva" ,
    "sivel2_gen_victimacolectiva_vinculoestado"
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


  def presentar
    authorize! :read, ::Diccionariodatos
    @registros = nil
    @motor_nombre = ""
    @motor_version = ""
    @motor_nombre_rayas = ""
    @motor_arch_desc = ""
    @motor_descripcion = ""
    @motor_tablas = []
    @motor_relaciones = []
    if params && params[:diccionariodatos] &&
        params[:diccionariodatos][:motor] &&
        MOTORES.include?(params[:diccionariodatos][:motor])

      @motor_nombre = params[:diccionariodatos][:motor]
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
            clase = (@motor.to_s+"::"+ncorto.camelize).constantize
            if clase && clase.respond_to?(:all) && 
                clase.all.respond_to?(:count)
              registros = clase.all.count
            end
            if desc != "" && clase.respond_to?(:columns)
              llave = clase.columns.map(&:name).include?("id") ? "id" : ""
              atributos = clase.columns.map(&:name) - ["id"]
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

    if params["exportar"]
      narch = "diccionariodatos-#{@motor}-#{Time.now.strftime "%Y%m%d%H%M%S"}.xlsx"
      n = self.exportar_excel(narch)
      send_file(
        n,
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        disposition: "attachment",
        filename: narch
      )
    else
      respond_to do |format|
        format.html {
          render 'diccionariodatos/presentar',
          layout: 'application'
        }
        format.json { head :no_content }
        format.js   { head :no_content }
      end
    end
  end


  def exportar_excel(narch)
    p = Axlsx::Package.new
    lt = p.workbook
    e = lt.styles

    estilo_base = e.add_style sz: 12
    estilo_titulo = e.add_style sz: 20
    estilo_enc1 = e.add_style sz: 16
    estilo_encabezado = e.add_style sz: 12, b: true, 
      alignment: { wrap_text: true }
    estilo_varias_lineas = e.add_style sz: 12, alignment: { wrap_text: true }
    #, fg_color: 'FF0000', bg_color: '00FF00'

    lt.add_worksheet do |hoja|
      hoja.add_row ['Diccionario de Datos'],
        height: 30, style: estilo_titulo
      hoja.merge_cells("A1:E1")

      hoja.add_row []
      hoja.add_row ["Motor:", @motor],
        style: [estilo_encabezado, estilo_base]
      hoja.add_row ["Versión:", @motor_version ],
        style: [estilo_encabezado, estilo_base]
      hoja.add_row ["Hora:", Time.now.to_s ],
        style: [estilo_encabezado, estilo_base]

      hoja.add_row []

      hoja.add_row ['Tablas'],
        height: 30, style: estilo_enc1
      hoja.merge_cells("A7:E7")

      numfilas = 6
      hoja.add_row [ "Item", 
                     "Nombre", 
                     "Descripción", 
                     "Llave primaria", 
                     "Atributos" ], 
                     style: [estilo_encabezado] * numfilas

      item = 1
      @motor_tablas.each do |t|
        l2 = [
          item,
          t[:nombre],
          t[:descripcion],
          t[:llave_primaria],
          t[:atributos].join(",")
        ]
        hoja.add_row l2, style: estilo_varias_lineas 
        item += 1
      end

      hoja.add_row []

      hoja.add_row ['Relaciones'],
        height: 30, style: estilo_enc1
      hoja.merge_cells("A#{item+9}:E#{item+9}")  

      numfilas = 6
      hoja.add_row [ "Item", 
                     "Nombre", 
                     "Descripción", 
                     "Llave primaria", 
                     "Atributos" ], 
                     style: [estilo_encabezado] * numfilas

      item = 1
      @motor_relaciones.each do |t|
        l2 = [
          item,
          t[:nombre],
          t[:descripcion],
          t[:llave_primaria],
          t[:atributos].join(",")
        ]
        hoja.add_row l2, style: estilo_varias_lineas 
        item += 1
      end

      anchos = [10, 20, 80, 10, 80]
      hoja.column_widths(*anchos)

    end

    n=File.join('/tmp', File.basename(narch + ".xlsx"))
    p.serialize n
    return n

  end



  def diccionariodatos_params
    params.require(:diccionariodatos).permit(
      :motor
    )
  end


end
