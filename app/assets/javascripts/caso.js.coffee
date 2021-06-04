

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

# En formulario de caso-migracion si elige otro miembro familiar, muestra campo para especificarla
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=miembrofamiliar_id]', (e) ->
  res = $(this).val()
  id_miembro = $(this).attr('id') 
  div_otracausa = $('#' + id_miembro).parent().next()
  if (res == '6')
    div_otracausa.css("display", "block")
  else
    div_otracausa.css("display", "none")
)

# En formulario de caso-migracion si elige otra autoridad ante la cual declarar, muestra campo para especificarla
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=autoridadrefugio_id]', (e) ->
  res = $(this).val()
  id_auto = $(this).attr('id') 
  div_otracausa = $('#' + id_auto).parent().next()
  if (res == '5')
   div_otracausa.css("display", "block")
  else
   div_otracausa.css("display", "none")
)

# En formulario de caso-migración si en causa de la agresión es Otra agrega respuesta abierta
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=causaagresion_ids]', (e) ->
  res = $(this).val()
  id_causaagresion = $(this).attr('id')
  div_otra = $('#' + id_causaagresion).parent().next()
  if (res.includes('8'))
   div_otra.css("display", "block")
  else
   div_otra.css("display", "none")
)

# En formulario de caso-migracion si pagó por ingreso a colombia muestra campos de detalles
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=pagoingreso_id]', (e) ->
  res = $(this).val()
  id_pago = $(this).attr('id').replace('pagoingreso_id', 'valor_pago')  
  div_detalles = $('#' + id_pago).closest('.detalles_pago')
  if (res == '2')
   div_detalles.css("display", "block")
  else
   div_detalles.css("display", "none")
)

# En formulario de caso-migración si en causa agresión en país  es Otra agrega respuesta abierta
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=causaagrpais_ids]', (e) ->
  res = $(this).val()
  id_causaagresion = $(this).attr('id')
  div_otra = $('#' + id_causaagresion).parent().next()
  if (res.includes('8'))
    div_otra.css("display", "block")
  else
   div_otra.css("display", "none")
)

# En formulario de caso-migración si en agresión durante la migración es Otra agrega respuesta abierta
$(document).on('change', 'select[id^=caso_migracion_attributes_][id$=agresionmigracion_ids]', (e) ->
  res = $(this).val()
  id_agresion = $(this).attr('id')
  div_otra = $('#' + id_agresion).parent().next()
  if (res.includes('13'))
   div_otra.css("display", "block")
  else
   div_otra.css("display", "none")
)

# En migración, si cambia fecha se calcula el tiempo en el país
$(document).on('change', 'input[id^=caso_migracion_attributes_][id$=_fechallegada]', (e) ->
  input_dias = $('input[id^=caso_migracion_attributes_][id$=_tiempoenpais]')
  divtiempoenpais = $(this).parent().parent().parent().next().find($(".div_tiempo"))
  tiempoenpais = $(this).parent().parent().parent().next().find(input_dias)
  divtiempoenpais.css("display", "block")
  fechallegada = new Date($(this).val())
  fechahoy = new Date()
  dif = fechahoy - fechallegada;
  dias = Math.round(dif / 86400000);
  tiempoenpais.val(dias)
)


# Llena campos clasificacion y subclasificacion de desplazamiento
@llena_clasifdesp = (ide, idl, jqthis) ->
  ee = $("#" + ide)
  ve = ee.val()
  te = $('#' + ide + " option[value='" + ve + "']").text()
  #fe = ee.find('option[value=' + ve + ']')
  #te = fe.text()	
  pe = te.split(" / ")
  el = $("#" + idl)
  vl = el.val()
  tl = $('#' + idl + " option[value='" + vl + "']").text()
  #fl = el.find('option[value=' + vl + ']')
  #tl = fl.text()
  pl = tl.split(" / ")
  cl = ""
  if pe.length > 0 && pl.length > 0
    if pe[0] != pl[0] 
      cl = "TRANSFRONTERIZO"
    else
      cl = "INTERDEPARTAMENTAL"
      if pe.length > 1 && pl.length > 1 && pe[1] == pl[1]
        cl = "INTERMUNICIPAL"
        if pe.length > 2 && pl.length > 2 && pe[2] == pl[2]
          cl = "DENTRO DE UN MUNICIPIO"
          if pe.length == 4 && pl.length == 4 && pe[3] == pl[3]
            cl = "INTRAURBANO"
  ue = "RURAL"
  if pe.length == 4
    ue = "URBANO"
  ul = "RURAL"
  if pl.length == 4
    ul = "URBANO"
  jqthis.parent().parent().find('input[name=clasificacion]').val(cl)
  jqthis.parent().parent().find('input[name=subclasificacion]').val(ue + " - " + ul)

# En desplazamientos al cambiar sitio de salida o llegada se recalcula clasificación y subclasificación de desplazamiento
$(document).on('change', 'select[id^=caso_desplazamiento_attributes_][id$=id_expulsion]', (e) ->
  ide=$(this).attr('id')
  idl=ide.replace('expulsion', 'llegada') 
  llena_clasifdesp(ide, idl, $(this))
)

# En desplazamientos, lista de sitios de llegada se cálcula
$(document).on('change', 'select[id^=caso_desplazamiento_attributes_][id$=id_llegada]', (e) ->
  idl=$(this).attr('id')
  ide=idl.replace('llegada', 'expulsion') 
  llena_clasifdesp(ide, idl, $(this))
)


# Al pasar a pestaña desplazamientos se recalculan clasificaciones
$(document).on('click', 'a.fichacambia[href^="#desplazamiento"]', (e) ->
  # e.preventDefault() No prevenir para que opere normal el cambio de
  # pestaña que implementa sivel2_sjr
  $('select[id^=caso_desplazamiento_attributes_][id$=id_expulsion]').
    each((i, e) -> 
      ide=$(e).attr('id')
      idl=ide.replace('expulsion', 'llegada') 
      llena_clasifdesp(ide, idl, $(e))
      return
   )
  return
)


@agregar_colapsables_cocoon = (nombrecampo, posicion) ->
  hijos = $('.nested-fields.vic').length
  hijo = $('.nested-fields.vic')[posicion]
  id = posicion + 1
  objeto = $(hijo)
  if hijos > 0
    iditem = nombrecampo + 'colapsable' + id
    objeto.find('h3.tituloenlace').text('Integrante ' + id)
    objeto.find('a.itemvictima').attr('data-toggle', 'collapse')
    objeto.find('a.itemvictima').attr('href', '#' + iditem)
    objeto.find('div.divcolapse').attr('id', iditem)

$(document).on('cocoon:after-insert', '', (e, victima) ->
  hijos = $('.nested-fields.vic').length
  agregar_colapsables_cocoon('victima', hijos-1)
)

document.addEventListener('turbolinks:load', () ->
  items_victimas = $('.nested-fields.vic')
  if items_victimas.length > 0
    for item in [0 .. items_victimas.length-1]
      agregar_colapsables_cocoon('victima', item)
)

# Agrega actos  
$(document).on('click', 'a.agregaractos[href^="#"]', (e) ->
  e.preventDefault()
  root =  exports ? window
  desplazamiento = $(this).attr('data-desplazamiento')
  if(desplazamiento == "")
    if($(this).closest(".actos_tabla").parent().attr("id") != "actos_tabla")
      id_tabla = $(this).closest(".actos_tabla").parent().attr("id")
      desplazamiento = id_tabla.split("_")[1]
  tn = Date.now()
  d = -1
  if (root.tagregaactos) 
    d = (tn - root.tagregaactos)/1000
  if (d == -1 || d>5) 
    f=$('form')
    a = root.puntomontaje + 'actos/agregar?desplazamiento=' + desplazamiento
    $.post(a, f.serialize())
    root.tagregaactos= Date.now()
  return
)
