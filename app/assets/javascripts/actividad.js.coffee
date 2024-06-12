
# En listado de asistencia permite autocompletar nombres
$(document).on('focusin',
  'input[id^=actividad_ubicacionpre_mundep_texto]', (e) -> 
   msip_busca_ubicacionpre_mundep($(this))
)

# En formulario de actividad si escoge Plan Estratégico se elimina el boton eliminar mde la fila
$(document).on('change', 'select[id^=actividad_actividad_proyectofinanciero_attributes][id$=_proyectofinanciero_id]', (e) ->
  if $(this).val() == "10"
    $($(this).parent().parent().siblings()[1]).css("display", "none")
  else
    $($(this).parent().parent().siblings()[1]).css("display", "block")
)
# En formulario de caso-migracion si elige otra causa muestra campo para especificarla
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=causamigracion_id]', (e) ->
  res = $(this).val()
  id_causa = $(this).attr('id') 
  div_otracausa = $('#' + id_causa).parent().next()
  if (res == '11')
   div_otracausa.css("display", "block")
  else
   div_otracausa.css("display", "none")
)

@cor1440_gen_busca_asistente = (ej) ->
  return

# En listado de asistencia permite autocompletar nombres
#$(document).on('focusin',
#'input[id^=actividad_asistencia_attributes_]'+
#'[id$=_persona_attributes_numerodocumento]',
#(e) ->
#  cor1440_gen_busca_asistente($(this))
#)

@filtra_actividadespf_tipo_accionhum = (apfs_ids) ->
  root = window
  f_actividadespf = 'filtro[busid]=' + apfs_ids.join(",")
  f_tipo = 'filtro[busactividadtipo_id]=129'
  buscatipoactividad = (e, resp) ->
    div_detallefinanciero = $("#detallefinanciero")
    if resp.length > 0
      div_detallefinanciero.css("display", "block")
    else
      div_detallefinanciero.css("display", "none")
  msip_ajax_recibe_json(root, 'actividadespflistado.json?' + f_actividadespf + '&' + f_tipo, null, buscatipoactividad)

@valida_visibilidad_detallefinanciero = () ->
  actividadespf = []
  $('select[id^=actividad_actividad_proyectofinanciero_attributes_][id$=actividadpf_ids]').each( () ->
    val = $(this).val()
    actividadespf = $.merge(actividadespf, val)
  )
  filtra_actividadespf_tipo_accionhum(actividadespf)


@actualiza_opciones_convenioactividad = () ->
  apfs_total = calcula_pfapf_seleccionadas()
  apfs = apfs_total[0]
  apfs_abreviadas = apfs_total[1]
  $('select[id^=actividad_detallefinanciero_attributes_][id$=convenioactividad]').each((o) ->
    if $(this).val() == "" || $(this).val() == null
      miselect = $(this)
      miselectid = $(this).attr('id')
      nuevasop = apfs
      nuevasop_text = apfs_abreviadas
      miselect.empty()
      $(nuevasop).each( (o) ->
        miselect.append($("<option></option>")
         .attr("value", nuevasop[o]).text(nuevasop_text[o]))
      )
      $('#' + miselectid).val('')
      em = document.querySelector('#' + miselectid)
      Msip__Motor.refrescarElementoTomSelect(em)
  )

@calcula_pfapf_seleccionadas = () ->
  apfs = []
  apfs_abreviadas = []
  $('[id^=actividad_actividad_proyectofinanciero_attributes][id$=_actividadpf_ids] option:selected').each( (o) ->
    v = $(this).text()
    pf = $(this).parent().parent().parent().prev().find('select[id$=_proyectofinanciero_id] option:selected').text()
    apf_sincod = v.substr(v.indexOf(': ')+1)
    if (pf != "" && pf != "PLAN ESTRATÉGICO 1" && apf_sincod != "")
      valor = pf + " -" + apf_sincod
      if (pf.length > 6)
        valor_abre = pf.substring(0, 5) + "..." + " -" + apf_sincod
      else
        valor_abre = valor
      apfs.push(valor)
      apfs_abreviadas.push(valor_abre)
  )
  return [apfs, apfs_abreviadas]
  
$(document).on('change', 'select[id^=actividad_actividad_proyectofinanciero_attributes_][id$=actividadpf_ids]', (e, res) ->
  valida_visibilidad_detallefinanciero()
  actualiza_opciones_convenioactividad()
)

$(document).on('cocoon:after-insert', '#actividad_proyectofinanciero', (e, objetivo) ->
  if objetivo.children()[0].children[1].children[0].selectedOptions[0].text != "PLAN ESTRATÉGICO 1"
    $(objetivo.children()[2]).css("display", "block")
  else
    $(objetivo.children()[2]).css("display", "none")
)

$(document).on('cocoon:after-remove', '#actividad_proyectofinanciero', (e, objetivo) ->
  valida_visibilidad_detallefinanciero()
  actualiza_opciones_convenioactividad()
)

$(document).on('cocoon:after-insert', '#filas_detallefinanciero', (e, objetivo) ->
  window.Msip__Motor.configurarElementosTomSelect()
  actualiza_opciones_convenioactividad()
  # Tras agregar fila a detalle financiero refrescar beneficiarios posibles
  jrs_refresca_posibles_beneficiarios_asistentes()
 )

$(document).on('change', 'select[id^=actividad_detallefinanciero_attributes_][id$=convenioactividad]', (e, res) ->
  $(e.target).attr('disabled', true)
  Msip__Motor.configurarElementoTomSelect(e.target)
)
$(document).on('change', 'select[id^=actividad_detallefinanciero_attributes_][id$=_modalidadentrega_id]', (e, res) ->
  valor = +$(this).val()
  tipotrans = $(this).parent().next()
  if valor != 1
    tipotrans.css('display', 'block')
  else
    tipotrans.css('display', 'none')
)

$(document).on('change', 'input[id^=actividad_detallefinanciero_attributes_][id$=_numeromeses]', (e, res) ->
  total = +$(this).val()
  numeroasistencia = $(this).parent().parent().next().find("select")
  $(numeroasistencia).empty()
  opciones = ''
  opciones += '<option value='+i+'>'+i+'</option>' for i in [1..total]
  $(numeroasistencia).append(opciones)
)

@recalcular_detallefinanciero_valortotal = (fila) ->
  cantidad = +fila.find('input[id^=actividad_detallefinanciero_attributes][id$=_cantidad]').val()
  total = +fila.find('input[id^=actividad_detallefinanciero_attributes][id$=_valortotal]').val()
  numbenef = 0
  if typeof fila.find('select[id^=actividad_detallefinanciero_attributes][id$=_persona_ids]').val() == 'object'
    numbenef = fila.find('select[id^=actividad_detallefinanciero_attributes][id$=_persona_ids]').val().length
  if (cantidad * numbenef) != 0
    valorunitario = Math.round(total / (cantidad * numbenef))
    fila.find('input[id^=actividad_detallefinanciero_attributes][id$=_valorunitario]').val(valorunitario)

$(document).on('change', 'input[id^=actividad_detallefinanciero_attributes][id$=_cantidad]', (e, res) ->
  recalcular_detallefinanciero_valortotal($(this).parent().parent().parent())
)

$(document).on('change', 'input[id^=actividad_detallefinanciero_attributes][id$=_valortotal]', (e, res) ->
  recalcular_detallefinanciero_valortotal($(this).parent().parent().parent())
)

$(document).on('change', 'select[id^=actividad_detallefinanciero_attributes][id$=_persona_ids]', (e, res) ->
  recalcular_detallefinanciero_valortotal($(this).parent().parent().parent())
)

#
#  ACTUALIZA DINAMICAMENTE BENEFICIARIO(S) DIRECTO(S) EN DETALLEFINANCIERO
#


@jrs_persona_presenta_nombre = (nombres, apellidos, tdocumento_sigla = null, numerodocumento = null) ->
  ip = ''
  if typeof numerodocumento != 'undefined'  && numerodocumento != ''
    ip = numerodocumento
  if typeof tdocumento_sigla != 'undefined' && tdocumento_sigla != ''
    ip = tdocumento_sigla + ":" + ip
  r = nombres + " " + apellidos + " (" + ip + ")"
  r

@jrs_refresca_posibles_beneficiarios_asistentes = () ->
  # Recorre listado de asistentes (sin _destroy) para recolectar personas 
  # y de cada una lo necesario para presentarlas en columna Beneficiario(s) 
  # Directo(s) del detalle financiero

  posbenef = []

  $('[id^=actividad_asistencia_attributes][id$=__destroy]').each((i,v) ->
    # excluye asistentes destruidos
    if $(this).val() != "1"
      personaid = $(this).parent().parent().find("[id$=_persona_attributes_id]").val()
      nombres = $(this).parent().parent().find("[id$=_nombres]").val()
      apellidos = $(this).parent().parent().find("[id$=_apellidos]").val()
      tdocumento_sigla = $(this).parent().parent().find("[id$=_tdocumento_id]").children('option:selected').text()
      numerodocumento = $(this).parent().parent().find("[id$=_numerodocumento]").val()
      n = jrs_persona_presenta_nombre(nombres, apellidos, tdocumento_sigla, numerodocumento)
      posbenef.push({id: personaid, nombre: n})
  )

  posbenef.sort((a, b) ->
    na = a.nombre.toUpperCase()
    nb = b.nombre.toUpperCase()
    if na < nb
      -1
    else if na > nb
      1
    else
      0
  )

  posbenefu = posbenef.filter( (valor, indice, self) ->
    self.indexOf(valor) == indice
  )
  # Aquí modificamos los campos beneficiario_directo
  $('[id^=actividad_detallefinanciero_attributes_][id$=__destroy]').each((i,v) ->
    # Excluye filas de detalle destruidas
    if $(this).val() != "1"
      idpi = $(this).parent().parent().find("[id$=_persona_ids]").attr('id');
      msip_remplaza_opciones_select(idpi, posbenefu, true);
  )

# En actividad tras cambiar nombres de asistente refrescar beneficiario posibles
$(document).on('change', '[id^=actividad_asistencia_attributes][id$=_nombres]', (e, objetivo) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# En actividad tras cambiar apellidos de asistente refrescar beneficiario posibles
$(document).on('change', '[id^=actividad_asistencia_attributes][id$=_apellidos]', (e, objetivo) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# En actividad tras cambiar tipo de documento refrescar beneficiario posibles
$(document).on('change', '[id^=actividad_asistencia_attributes][id$=_tdocumento_id]', (e, objetivo) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# Tras cambiar número de documento refrescar beneficiario posibles
$(document).on('change', '[id^=actividad_asistencia_attributes][id$=_numerodocumento]', (e, objetivo) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# Tras eliminar asistente refrescar beneficiarios posibles
$(document).on('cocoon:after-remove', '#asistencia', (e, papa) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# Tras autocompletar asistente refrescar beneficiarios posibles
$(document).on('cor1440gen:autocompletado-asistente', (e, papa) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# Tras autocompletar caso beneficiario refrescar beneficiarios posibles
$(document).on('sivel2sjr:autocompletado-contactoactividad', (e, papa) ->
  console.log('entro por evento autocompletado-contactoactividad')
  jrs_refresca_posibles_beneficiarios_asistentes()
)


# En caso de que ocurra un error de valida
$(document).on('focusin', '.actividad_detallefinanciero_persona', (e, papa) ->
  jrs_refresca_posibles_beneficiarios_asistentes()
)

# En caso de que en detalle financiero 
# se seleccione el proyecto financiero y convenio se busca si han habido otros
# detalles financierosc con este poryecto/convenio y estos beneficiarios
# así, se deshabilita el campo numeromeses y se redefinen opciones de
# numeroasistencia

$(document).on('change', 'select[id^=actividad_detallefinanciero_attributes][id$=_persona_ids]', (e) ->
  beneficiarios = $(this).val()
  eleconvenio = $(this).parent().parent().prev().find("[id$=_convenioactividad]")
  busca_detallesfinancieros_anteriores(beneficiarios, eleconvenio)
)
$(document).on('change', 'select[id^=actividad_detallefinanciero_attributes][id$=_convenioactividad]', (e) ->
  idpi = $(this).parent().parent().next().find("[id$=_persona_ids]").attr('id')
  eleconvenio = $(this)
  beneficiarios = $("#"+ idpi).val()
  busca_detallesfinancieros_anteriores(beneficiarios, eleconvenio)
)

@busca_detallesfinancieros_anteriores = (beneficiarios, eleconvenio) ->
  convenio = eleconvenio.val()
  elenm = $(eleconvenio.parent().parent().siblings()[8]).find("[id$=_numeromeses]")
  elena = $(eleconvenio.parent().parent().siblings()[9]).find("[id$=_numeroasistencia]")
  if beneficiarios.length > 0 && convenio
    root = window
    rutac = root.puntomontaje + 'revisaben_detalle'
    $.ajax({
      url: rutac, 
      data: {pf: convenio, ben_ids: beneficiarios},
      dataType: 'json',
      method: 'GET'
    }).fail( (jqXHR, texto) ->
      alert('Error - ')
    ).done( (datos, r) ->
      if datos.respuesta == true
        elenm.val(datos.numeromeses)
        elenm.prop('disabled', 'disabled');
        Msip__Motor.configurarElementoTomSelect(elenm)
        msip_remplaza_opciones_select(elena.attr('id'), datos.asistencias, true);
      else
         elenm.removeAttr('disabled');
         elenm.val("")
         Msip__Motor.configurarElementoTomSelect(elenm)
         elena.empty()
         Msip__Motor.configurarElementoTomSelect(elena)
    )


$(window).on('keyup keypress', (e) ->
  if document.URL.match(/\/actividades\/[0-9]*\/edita/)
    if e.keyCode == 13
      return false;
)
