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
    [ :numfila ]
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
      analizador = SQLParser::Parser.new
      begin
        asa = analizador.scan_str(params[:filtro][:consultasql].to_s).
          to_sql.gsub("`", "\"")
        Rails.logger.info "En consultabd_controller consulta: #{asa}"
        Consultabd.refresca_consulta(
          asa, request.remote_ip, current_usuario.id, request.url, params
        )
        @registros = Consultabd.all
      rescue StandardError => e
        Rails.logger.info "Excepción en consultabd_controller: #{e.to_s}"
        flash[:error] = "No se logró reconocer consulta SELECT en SQL '#{params[:filtro][:consultasql].to_s}'"
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

end
