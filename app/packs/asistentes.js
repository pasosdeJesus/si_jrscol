// Suponemos que application.js ya hizo:
// import Rails from "@rails/ujs"
// windows.Rails=Rails

export default class Asistentes {

  // Funciones adaptadas de https://codepen.io/jrio/pen/dNKLMR por Joao Rodrigues
  static URL = "/personas.json";
  static idDatalist = "fuente-asistentes"
  static claseEnvoltura = "campos_asistente"

  /**
   * Añade opciones al datalist (proceso lo obtenido con AJAX)
   * @param {array} resp - arreglo de opciones para el datalist
   */
  static autocompletar_llena_datalist(resp) {
    console.log("OJO autocompletar_llena_datalist, resp="+resp)
    // Get items from rsp not available in cache
    let frag = document.createDocumentFragment();
    resp.forEach(item => {
      let opcion = document.createElement("option");
      [opcion.id, opcion.text] = [item['id'], item['value']];
      frag.appendChild(opcion);
    });
    let sel = document.getElementById(Asistentes.idDatalist);
    sel.innerHTML=''
    if (frag.hasChildNodes()) {
      sel.appendChild(frag);
    }
  };

  /**
   * Usa texto tecleado por el usuario de más de 4 caracteres
   * para hacer llamada AJAX que busca con ese término y
   * después ejecuta autocompletar_llena_datalist con el resultado
   * @param {event} e evento
   */
  static autocompletar_busca(e) {
    if (e.target.getAttribute('data-autocompleta') === 'no') {
      console.log("OJO ya no autocompleta")
      return
    }
    const val = e.target.value;
    console.log('OJO autocompletar_busca, val='+val)
    if (val.length < 4) return; 
    let url = Asistentes.URL+'?term='+val
    window.Rails.ajax({
      type: "GET",
      url: url,
      data: null,
      success:  function (resp, estado, xhr) {
        Asistentes.autocompletar_llena_datalist(resp)
      },
      error: function (req, estado, xhr) {
        alert(`No pudo consultarse listado de personas.`)
      },
      data: null
    })

    /*    let req = new XMLHttpRequest();
    req.onload = () => {
      if (req.status === 200) { // success
      }
    };
    req.onerror = () => alert(`No pudo consultarse listado de personas.`);
    console.log('OJO autocompletar_busca antes de open')
    req.open("GET", url, true); 
    req.setRequestHeader("Content-type",
      "application/x-www-form-urlencoded");
    req.setRequestHeader('Accept', 'application/json');
    req.send(); */
  };

  // Elije una persona en autocompletación
  static autocompletacion_elegida(cadpersona, id, eorig, root=window) {
    sip_arregla_puntomontaje(root)
    let cs = id.split(";")
    let id_persona = cs[0]
    let pl = []
    let ini = 0
    cs.forEach((s, i) => {
      let t = parseInt(s)
      pl[i] = cadpersona.substring(ini, ini + t)
      ini = ini + t + 1
    })
    // pl[1] cnom, pl[2] es cape, pl[3] es cdoc
    let d = "&id_persona=" + id_persona
    d += "&ac_asistente_persona=true"
    let a = root.puntomontaje + 'personas/datos'

    window.Rails.ajax({
      type: "GET",
      url: a,
      data: d,
      success:  function (resp, estado, xhr) {
        let divcp = eorig.target.closest('.' + Asistentes.claseEnvoltura)
        divcp.querySelector('[id$=_attributes_id]').value = resp.id
        divcp.querySelector('[id$=_attributes_nombres]').value = resp.nombres
        divcp.querySelector('[id$=_attributes_apellidos]').value = resp.apellidos
        divcp.querySelector('[id$=_attributes_sexo]').value = resp.sexo
        let tdocid = divcp.querySelector('[id$=_attributes_tdocumento_id]')
        if (tdocid != null) {
          tdocid.value = resp.tdocumento
          /*option:contains(' +
        resp.tdocumento + ')').value
        var xpath = "//datalist[@id='fuente-personas']/option[text()='" +
          e.target.value + "']"
        var o= document.evaluate(xpath, document, null, 
          XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        if (typeof(o.id) == 'string') {
          autocompletacion_elegida(e.target.value, o.id, e)

          divcp.querySelector('[id$=_tdocumento_id]').value = tdocid */
        }
        let numdoc = divcp.querySelector('[id$=_numerodocumento]')
        if (numdoc != null) {
          numdoc.value = resp.numerodocumento
        }
        let anionac = divcp.querySelector('[id$=_anionac]')
        if (anionac != null) {
          anionac.value = resp.anionac
        }
        let mesnac = divcp.querySelector('[id$=_mesnac]')
        if (mesnac != null) {
          mesnac.value = resp.mesnac
        }
        let dianac = divcp.querySelector('[id$=_dianac]')
        if (dianac != null) {
          dianac.value = resp.dianac
        }
        let cargo=divcp.querySelector('[id$=_cargo]')
        if (cargo != null) {
          cargo.value = resp.cargo
        }
        let correo = divcp.querySelector('[id$=_correo]')
        if (correo != null) {
          correo.value = resp.correo
        }
        eorig.target.setAttribute('data-autocompleta', 'no')
        eorig.target.removeAttribute('list')
        let sel = document.getElementById(Asistentes.idDatalist);
        sel.innerHTML = ''
      },
      error: function (resp, estado, xhr) {
        alert("Error con ajax " + resp)
      }
    })

    return
  }


  static iniciar() {
    /**
     * Detecta teclas levantadas para mejorar listado de datalist
     * @param {event} e evento
     */
    document.addEventListener('keyup', function (e) {
      console.log('OJO keyup ' + e.target.id)
      if (/^actividad_asistencia_attributes_[0-9]*_persona_attributes_numerodocumento$/.test(e.target.id)) {
        Asistentes.autocompletar_busca(e)
      }

    }, false)

    // Solución para diferenciar cuando se teclea o cuando se elije basada en
    // la de Dan en https://stackoverflow.com/questions/30022728/perform-action-when-clicking-html5-datalist-option

    var teclapresionada = false

    /**
     * Detecta teclas presionadas para diferenciar algo tecleado de click en opción
     * @param {event} e evento
     */
    document.addEventListener('keydown', function (e) {
      console.log('OJO keydown ' + e.target.id)
      if (/^actividad_asistencia_attributes_[0-9]*_persona_attributes_numerodocumento$/.test(e.target.id)) {
        if(e.key) {
          teclapresionada = true;
        }
      }
    }, false)


    /**
     * Detecta cuando se elige una de las opciones autocompletadas.
     * @param {event} e evento
     */
    document.addEventListener('input', function (e) {
      console.log('OJO input ' + e.target.id)
      if (/^actividad_asistencia_attributes_[0-9]*_persona_attributes_numerodocumento$/.test(e.target.id)) {
        if (teclapresionada === false) {
          console.log("OJO aquí está el problema con datalist porque no tenemos forma de saber el id de la opción elegida, e.target.value tiene el texto, pero podría haber varias entradas con el mismo texto. Lo menos peor que se puede hacer es buscar entra las opciones la primera cuyo texto coincida y elegir esa")
          var el=document.querySelector('#' + Asistentes.idDatalist)
          var idop = null
          el.childNodes.forEach(function (o) {
            if (o.innerText.replace(/  */g, ' ') == e.target.value) {
              idop = o.id
            }
          })

          if (idop != null) {
            Asistentes.autocompletacion_elegida(e.target.value, idop, e)
            e.stopPropagation()  // No hace burbuja
            e.preventDefault() // No ejecuta acción predeterminada
          } else {
            alert('Problema para identificar opción elegida')
          }
        }
        teclapresionada = false
      }

    }, false)
  }


}


