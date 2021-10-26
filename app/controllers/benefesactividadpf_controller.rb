class BenefesactividadpfController < Heb412Gen::ModelosController

  
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


end
