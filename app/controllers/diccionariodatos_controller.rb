class DiccionariodatosController < ApplicationController

  load_and_authorize_resource class: ::Diccionariodatos

  # En orden de apilamiento
  MOTORES = Rails.configuration.railties_order.map {|m|
    m.to_s == "main_app" ? "SiJrscol" : m.to_s.split(':')[0]
  } - ["all", "Jos19"]

  TABLAS_NO_USADAS_EN_JRSCOL = [
    "ar_internal_metadata", 
    "causaref", 
    "cor1440_gen_anexo_efecto",
    "cor1440_gen_actividadtipo",
    "cor1440_gen_actividadtipo",
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
    "schema_migrations" ,
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
    "sivel2_gen_victimacolectiva_vinculoestado",
    "sivel2_sjr_accionjuridica_respuesta",
    "sivel2_sjr_actividad_casosjr",
    "sivel2_sjr_aslegal_respuesta",
    "sivel2_sjr_aspsocisocial_respuesta",
    "sivel2_sjr_ayudaestado_respuesta",
    "sivel2_sjr_ayudasjr_respuesta",
    "sivel2_sjr_derecho_procesosjr",
    "sivel2_sjr_derecho_respuesta",
    "sivel2_sjr_idioma",
    "sivel2_sjr_motivosjr_respuesta",
    "sivel2_sjr_oficina_proyectofinanciero",
    "sivel2_sjr_progestado_respuesta",
    "sivel2_sjr_progestado_respuesta",
    "sivel2_sjr_respuesta",
    
   
  ]


  def extraer_doc_de_clase_en_modulo(arch)
    if arch == "./app/models/asesorhistorico.rb"
      #debugger
    end
    pr = Prism.parse_file(arch)
    pr.attach_comments!
    cinst = pr.value.statements.body

    # Buscamos modulo
    m = 0
    while m < cinst.count && cinst[m].type != :module_node
      m += 1
    end
    if m >= cinst.count
      # No se encontró módulo intentamos con primer comentario
      if  pr.comments && pr.comments[0] && pr.comments[0].slice
        desc =pr.comments.map { |c| c.slice.gsub(/^# */, "") }.join("  ")
      else
        return "No se encontró módulo ni comentario al comienzo"
      end
    else
      # Extraemos documentación de la primera clase dentro del módulo
      b = cinst[m].slice
      l = 1
      desc = ""
      while l < b.lines.count && !(b.lines[l] =~ /^[\s]*class/)
        if b.lines[l] =~ /^[\s]*# ?(.*)/
            desc += " " + $1
        end
        l += 1
      end
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
      @motores_dir = {
        "SiJrscol" => "."
      }
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
      if (@motor_nombre == "SiJrscol") then
        @motor_nombre_rayas = "."
        motores_rayas = MOTORES.select {|m| m != "SiJrscol"}.map { |m|
          m.underscore
        }
        ltablas = ActiveRecord::Base.connection.tables.select {|n|
          motores_rayas.all?{|mr| !n.start_with?(mr + "_") } &&
            ActiveRecord::Base.connection.table_exists?(n) &&
            !TABLAS_NO_USADAS_EN_JRSCOL.include?(n)
        }
      else
        ltablas = ActiveRecord::Base.connection.tables.select {|n|
          n.start_with?(@motor_nombre_rayas + "_") &&
            ActiveRecord::Base.connection.table_exists?(n) &&
            !TABLAS_NO_USADAS_EN_JRSCOL.include?(n)
        }
      end
      ltablas.sort.each do |t|
        if @motor_nombre == "SiJrscol"
          if t[0..10] == "sivel2_sjr_"
            ncorto = t[11..-1]
            postarch = "sivel2_sjr/#{ncorto}.rb"
          else
            ncorto = t
            postarch = "#{ncorto}.rb"
          end
        else
          ncorto=t[(@motor_nombre_rayas.length+1)..-1]
          postarch = "#{@motor_nombre_rayas}/#{ncorto}.rb"
        end
        #if ncorto == 'campo'
        #  debugger
        #end
        # Buscar descripción no vacía que esté más arriba en la pila de
        # motores
        arch = ""
        clase = ""
        desc = ""
        llave = ""
        atributos = []
        llaves_foraneas = []
        registros = 0
        MOTORES.each do |m|
          parch = File.join(
            @motores_dir[m], "/app/models/#{postarch}"
          )
          if File.exist?(parch)
            arch = parch
            desc = extraer_doc_de_clase_en_modulo arch
            if @motor_nombre == "SiJrscol"
              if t[0..10] == "sivel2_sjr_"
                clase = ("Sivel2Sjr::" + ncorto.camelize).constantize
              else
                clase = ("::" + ncorto.camelize).constantize
              end
            else
              clase = (@motor.to_s + "::" + ncorto.camelize).constantize
            end
            if clase && clase.respond_to?(:all) && 
                clase.all.respond_to?(:count)
              registros = clase.all.count
            end
            if desc != "" && clase.respond_to?(:columns)
              clase.columns.each do |col|
                if col.name == "id"
                  llave = "id"
                else 
                  clf = nil
                  if clase.respond_to?(:asociacion_llave_foranea)
                    clf = clase.asociacion_llave_foranea(col.name)
                  end
                  if clf
                    if  clf.options[:class_name]
                      nomclf = clf.options[:class_name].parameterize.underscore
                    elsif clf.active_record
                      nomclf = clf.active_record.to_s.parameterize.underscore
                    else
                      puts "No se logra determinar clase de #{col.name}"
                      exit 1;
                    end
                    llaves_foraneas << col.name + "(" + nomclf + ")"
                  else
                    atributos << col.name + ":" + col.sql_type_metadata.sql_type
                  end
                end
              end
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
            llaves_foraneas: llaves_foraneas,
            registros: registros
          }
        else
          @motor_tablas << {
            nombre: t,
            descripcion: desc,
            llave_primaria: llave,
            atributos: atributos,
            llaves_foraneas: llaves_foraneas,
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
