class BenefesactividadpfController < Heb412Gen::ModelosController

  def clase
    '::Benefactividadpf'
  end

  def atributos_index
    if Benefactividadpf
      arr = Benefactividadpf.column_names
      primeros =["persona_id", "persona_nombre", "persona_identificacion", 
                 "persona_sexo", "edad_en_actividad", "rangoedadac_nombre"]
      primeros + (arr - primeros) - ["id"] 
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
    oficina = Sip::Oficina.habilitados.pluck(:id) 
    # Control de acceso
    #filtra_contarb_control_acceso

    # Parámetros
    @contarb_pfid = params[:filtro] && 
      params[:filtro][:proyectofinanciero_id] ?  
      params[:filtro][:proyectofinanciero_id].to_i : @contarb_pfid

    oficina = params[:filtro] && 
      params[:filtro][:oficina_id] && params[:filtro][:oficina_id] != "" ?  
      params[:filtro][:oficina_id].to_i : oficina
    @contarb_actividad = @contarb_actividad.where(oficina_id: oficina)
    @contarb_actividad = @contarb_actividad.where(
      'cor1440_gen_actividad.id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_proyectofinanciero
          WHERE proyectofinanciero_id=?)', @contarb_pfid).where(
            'cor1440_gen_actividad.id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_actividadpf)')

    if !params[:filtro] || !params[:filtro]['fechaini'] || 
        params[:filtro]['fechaini'] != ""
      if !params[:filtro] || !params[:filtro]['fechaini']
        @contarb_fechaini = Sip::FormatoFechaHelper.inicio_semestre_ant
      else
        @contarb_fechaini = Sip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro]['fechaini'])
      end
      @contarb_actividad = @contarb_actividad.where(
        'cor1440_gen_actividad.fecha >= ?', @contarb_fechaini)
    end

    if !params[:filtro] || !params[:filtro]['fechafin'] || 
        params[:filtro]['fechafin'] != ""
      if !params[:filtro] || !params[:filtro]['fechafin']
        @contarb_fechafin = Sip::FormatoFechaHelper.fin_semestre_ant
      else
        @contarb_fechafin = Sip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro]['fechafin'])
      end
      @contarb_actividad = @contarb_actividad.where(
        'cor1440_gen_actividad.fecha <= ?', @contarb_fechafin)
    end

    ## Activdiades de convenio según el filtro
    contarb_listaac = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: @contarb_pfid).order(:nombrecorto) 

    ## Fin filtros tabla index
    contarpro = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: @contarb_pfid)
    contarb_listaac ? contarb_listaac : []
    asistencias = Cor1440Gen::Asistencia.where(
      actividad_id: @contarb_actividad)
    @personasis = asistencias.pluck(:persona_id).uniq
    actividades = asistencias.pluck(:actividad_id).uniq
    lisp = @personasis.count> 0 ?
      @personasis.join(",") : "0"
    lisa = actividades.count> 0 ?
      actividades.join(",") : "0"
    crea_consulta(nil, lisp, lisa, contarpro)
  end


  def crea_consulta(ordenar_por = nil, lisp, lisa, contarb_listaac)
    if ARGV.include?("db:migrate")
      return
    end
    ActiveRecord::Base.connection.execute(
      "DROP MATERIALIZED VIEW IF EXISTS benefactividadpf")
    ActiveRecord::Base.connection.execute("
        CREATE MATERIALIZED VIEW benefactividadpf AS
        #{Benefactividadpf.subasis(lisp, lisa, contarb_listaac)}
      ")
    Benefactividadpf.reset_column_information
  end # def crea_consulta

end
