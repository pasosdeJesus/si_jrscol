
//= require caso_migracion

$(document).on('change',
  'input[type=radio][name$="[establecerse]"]',
  function (evento) {
    pid = evento.target.getAttribute('id').split('_')
    if (evento.target.value == "false") {
      d = 'block'
    } else {
      d = 'none'
    }
    $(evento.target).closest('.controls').
      find('[id^=ubicacionpre-destino]').css('display', d)
  }
)


msip_ubicacionpre_expandible_registra(
  'caso_desplazamiento_attributes', 'expulsion', window)

msip_ubicacionpre_expandible_registra(
  'caso_desplazamiento_attributes', 'llegada', window)

msip_ubicacionpre_expandible_registra(
  'caso_desplazamiento_attributes', 'destino', window)


$(document).on('cocoon:after-insert', '#desplazamiento',
  function (e, desplazamiento) {
    window.Msip__Motor.configurarElementosTomSelect()

    // Poner ids para expandir/contraer ubicaciones
    // Debe estar en sincronia con
    // app/views/msip/ubicacionpre/_dos_filas_confecha
    control = $('#ubicacionpre-expulsion-0').parent()
    cocoonid = control.find('[id$=fechaexpulsion]').attr('id').split('_')[3]

    console.log(cocoonid);

    ['expulsion', 'llegada', 'destino'].forEach(function (v, i) {
      msip_ubicacionpre_expandible_cambia_ids(v, cocoonid)
    })
    //asigna id de tabla actos al crear
    desplazamiento.find('.actos_div').attr("id", "actos_" + cocoonid)
    desplazamiento.find('.actos_tabla').attr("id", "actos_tabla_" + cocoonid)
    desplazamiento.find('#caso_acto_presponsable_id_').attr("name", "caso_acto_presponsable_id_" + cocoonid + "[]")
    desplazamiento.find('#caso_acto_presponsable_id_').attr("id", "caso_acto_presponsable_id_" + cocoonid)
    desplazamiento.find('#caso_acto_categoria_id_').attr("name", "caso_acto_categoria_id_" + cocoonid + "[]")
    desplazamiento.find('#caso_acto_categoria_id_').attr("id", "caso_acto_categoria_id_" + cocoonid)
    desplazamiento.find('#caso_acto_persona_id_').attr("name", "caso_acto_persona_id_" + cocoonid + "[]")
    desplazamiento.find('#caso_acto_persona_id_').attr("id", "caso_acto_persona_id_" + cocoonid)
    desplazamiento.find('#caso_acto_fecha_').attr("name", "caso_acto_fecha_" + cocoonid)
    desplazamiento.find('#caso_acto_fecha_').attr("id", "caso_acto_fecha_" + cocoonid)
    desplazamiento.find('#caso_acto_id_desplazamiento_').attr("name", "caso_acto_id_desplazamiento_" + cocoonid)
    desplazamiento.find('#caso_acto_id_desplazamiento_').attr("id", "caso_acto_id_desplazamiento_" + cocoonid)
    desplazamiento.find("#caso_acto_id_desplazamiento_" + cocoonid).val(cocoonid)
    desplazamiento.find('#nombre_nuevopr_').attr("name", "nombre_nuevopr_" + cocoonid)
    desplazamiento.find('#nombre_nuevopr_').attr("id", "nombre_nuevopr_" + cocoonid)
    desplazamiento.find('#papa_nuevopr_').attr("name", "papa_nuevopr_" + cocoonid)
    desplazamiento.find('#papa_nuevopr_').attr("papa", "nombre_nuevopr_" + cocoonid)
    desplazamiento.find('#observaciones_nuevopr_').attr("name", "observaciones_nuevopr_" + cocoonid)
    desplazamiento.find('#observaciones_nuevopr_').attr("id", "observaciones_nuevopr_" + cocoonid)
    $('#actos_tabla_' + cocoonid).find("tr:not(:last, :first)").remove();
  }
)
// al eliminar desplazamiento con coocon se eliminan sus actos
$(document).on('cocoon:before-remove', '#desplazamiento',
  function (e, desplazamiento) {
    botones_eliminar = desplazamiento.find('.eliminaracto')
    botones_eliminar.trigger("click")
  }
)
$(document).on("click", ".togglepr", function() {
 $(this).parent().siblings(".nuevopr").modal('toggle');
});
// Nuevo Presunto responsable desde actos
$(document).on("click", ".boton_agregarpr", function(e) {
  e.preventDefault()
  desplazamiento = $(this).attr('data-desplazamiento')
  if(desplazamiento == ""){
    if($(this).closest(".actos_tabla").parent().attr("id") != "actos_tabla"){
      id_tabla = $(this).closest(".actos_tabla").parent().attr("id")
      desplazamiento = id_tabla.split("_")[1]
    }
  }
  root =  window
  tn = Date.now()
  d = -1
  if (root.tagregapr){ 
    d = (tn - root.tagregapr)/1000
  }
  if (d == -1 || d>5){ 
    f=$('form')
    a = root.puntomontaje + 'actos/agregarpr?desplazamiento=' + desplazamiento
    $.post(a, f.serialize())
    root.tagregapr= Date.now()
  }
  return
});
