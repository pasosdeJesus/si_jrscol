
document.addEventListener('change', 
  function (event) {
    var m = event.target.id.match(/^caso_migracion_attributes_([0-9]*)_perfilmigracion_id$/)
    if (m != null) {
      var pd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_pais_id').parentElement;
      var dd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_departamento_id').parentElement;
      var md = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_municipio_id').parentElement;
      var cd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_centropoblado_id').parentElement;
      var fd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_fechaendestino').parentElement;
      if (event.target.checked) {
        pd.style.display = 'none'
        dd.style.display = 'none'
        md.style.display = 'none'
        cd.style.display = 'none'
        fd.style.display = 'none'
      } else {
        pd.style.display = ''
        dd.style.display = ''
        md.style.display = ''
        cd.style.display = ''
        fd.style.display = ''
      }

    }
  }
)

window.jrs_pre_agrega_paramscv = (numerr, elema, veccv, datos) => {
  document.body.style.cursor = 'default'
  if (numerr == 0) {
    jrs_agrega_paramscv(elema, veccv, datos)
    url = elema.getAttribute('href')
    window.open(url, '_blank').focus();
  } else {
    alert("Hay errores que no permiten guardar caso y crear actividad")
    document.getElementById("errores").focus();
  }
}

window.jrs_revisa_y_agrega_paramscv = (elema, evento, veccv, datos) => {
  evento.stopPropagation()
  evento.preventDefault()
  document.body.style.cursor = 'wait'
  idf = document.querySelector('form').getAttribute('id')
  listaidsrempl = ['errores']
  document.getElementById("errores").innerText=''
  msip_enviarautomatico_formulario_y_repinta_retrollamada3(idf, listaidsrempl,
    jrs_pre_agrega_paramscv, [elema, veccv, datos], 'POST')
}

