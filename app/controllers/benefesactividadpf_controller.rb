class BenefesactividadpfController < Heb412Gen::ModelosController

  def clase
    '::Benefactividadpf'
  end

  def atributos_index
    if Benefactividadpf
      Benefactividadpf.column_names - ["id"]
    end
  end

  def index
    contar_beneficiarios
    index_sip(Benefactividadpf.all)
  end


  def contar_beneficiarios
    @contarb_actividad = Cor1440Gen::Actividad.all
    @contarb_pf = Cor1440Gen::Proyectofinanciero.all
    contarb_pfid = nil
    oficina = Sip::Oficina.habilitados.pluck(:id) 
    # Control de acceso
    #filtra_contarb_control_acceso

    # Parámetros
    contarb_pfid = params[:filtro] && 
      params[:filtro][:proyectofinanciero_id] ?  
      params[:filtro][:proyectofinanciero_id].to_i : contarb_pfid

    oficina = params[:filtro] && 
      params[:filtro][:oficina_id] && params[:filtro][:oficina_id] != "" ?  
      params[:filtro][:oficina_id].to_i : oficina
    @contarb_actividad = @contarb_actividad.where(oficina_id: oficina)
    @contarb_actividad = @contarb_actividad.where(
      'cor1440_gen_actividad.id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_proyectofinanciero
          WHERE proyectofinanciero_id=?)', contarb_pfid).where(
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
      proyectofinanciero_id: contarb_pfid).order(:nombrecorto) 

    ## Fin filtros tabla index
    contarpro = Cor1440Gen::Actividadpf.where(proyectofinanciero_id: contarb_pfid)
    contarb_listaac ? contarb_listaac : []
    asistencias = Cor1440Gen::Asistencia.where(actividad_id: @contarb_actividad)
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
        #{subasis(lisp, lisa, contarb_listaac)}
      ")
    Benefactividadpf.reset_column_information
  end # def crea_consulta


  
  def subasis(lisp, lisa, actividadespf)
    c=" SELECT p.id,
       TRIM(TRIM(p.nombres) || ' '  ||
         TRIM(p.apellidos)) AS persona_nombre,
       TRIM(COALESCE(td.sigla || ':', '') ||
         COALESCE(p.numerodocumento, '')) AS persona_identificacion,
       p.sexo AS persona_sexo" 
       if actividadespf.count > 0
         c+= ", "   
         actividadespf.each do |apf|
           cod = apf.objetivopf.numero + apf.resultadopf.numero + apf.nombrecorto
           c+='(
                 SELECT COUNT(*) FROM cor1440_gen_asistencia AS asistencia
                 JOIN cor1440_gen_actividad_actividadpf AS aapf ON aapf.actividad_id=asistencia.actividad_id
                 WHERE aapf.actividadpf_id = ' + apf.id.to_s + '  
                 AND persona_id = p.id
                 AND asistencia.actividad_id IN (' + lisa + ') 
                 ) AS "'+ cod +'"' 
                  if apf != actividadespf.last
                    c += ', '
                  end
          end
        end
       c+="
       FROM sip_persona AS p
     JOIN cor1440_gen_asistencia AS asis ON asis.persona_id=p.id 
     LEFT JOIN sip_tdocumento AS td ON td.id=p.tdocumento_id
     JOIN cor1440_gen_actividad AS a ON asis.actividad_id=a.id
     WHERE p.id IN (#{lisp}) GROUP BY persona_identificacion, p.id"
  end

end
