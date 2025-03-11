class ConsultabdController < Heb412Gen::ModelosController

  load_and_authorize_resource class: ::Consultabd

  def clase
    '::Consultabd'
  end

  def atributos_index
    return columnas_posibles
  end

  def index_reordenar(c)
    c
  end 

  def vistas_manejadas
    ['Consultabd']
  end

  def columnas_posibles
    r = Consultabd.columns.map(&:name)
    r
  end

  def index_otros_formatos_campoid
    :numfila
  end

  # Genera listado
  def index
    @columnas = []
    if !ActiveRecord::Base.connection.data_source_exists?('consultabd')
        Consultabd.refresca_consulta(
          "SELECT 2 AS valor",
          request.remote_ip, 0, '', {}
        )
    end
    @registros = ::Consultabd.where(numfila: -1)
    if params && params[:filtro] && params[:filtro][:consultasql]
      begin
        #asa = analizador.scan_str(params[:filtro][:consultasql].to_s).
        #  to_sql.gsub("`", "\"")
        asa = PgQuery.parse(params[:filtro][:consultasql].to_s)
        Rails.logger.info "En consultabd_controller consulta: asa=#{asa}"
        if asa.tree.stmts[0].stmt.select_stmt
          # Es SELECT
          Consultabd.refresca_consulta(
            asa.query, request.remote_ip, current_usuario.id, 
            request.url, params
          )
          @registros = Consultabd.all
        else
          Rails.logger.info "No es SELECT"
          flash[:error] = "La consulta debe ser un SELECT"
        end
      rescue StandardError => e
        Rails.logger.info "Excepción en consultabd_controller: #{e.to_s}"
        flash[:error] = "No se logró reconocer consulta SELECT en SQL '#{params[:filtro][:consultasql].to_s}':<pre>#{CGI::escapeHTML(e.to_s)}</pre>".html_safe
        if !ActiveRecord::Base.connection.data_source_exists?('consultabd')
          Consultabd.refresca_consulta(
            "SELECT 2 AS valor",
            request.remote_ip, 0, '', {}
          )
        end
      end
    end
    index_msip(@registros)
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

end
