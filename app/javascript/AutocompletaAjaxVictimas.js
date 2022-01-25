
export default class AutocompletaAjaxVictimas {
  /* No usamos constructor ni this porque en operaElegida sería
   * del objeto AutocompletaAjaxExpreg y no esta clase.
   * Más bien en esta todo static
   */

  static claseEnvoltura = 'campos-persona-con-victima-id'
  static idDatalist = 'fuente-victimas'

  // Elije una persona en autocompletación
  static operarElegida (cadpersona, id, eorig) {
    let root = window
    sip_arregla_puntomontaje(root)
    const cs = id.split(';')
    const idPersona = cs[0]
    const divcp = eorig.target.closest('.' + AutocompletaAjaxVictimas.claseEnvoltura)
    const elemIdVictima = divcp.parentElement.querySelector('.caso_victima_id')
      .querySelector('input')
    if (typeof elemIdVictima == null) {
      window.alert('No se ubico .caso_victima_id')
      return
    }
    const idVictima = elemIdVictima.value

    let d = 'id_persona=' + idPersona
    d += "&id_victima=" + idVictima
    const a = root.puntomontaje + 'personas/remplazar'

    window.Rails.ajax({
      type: 'GET',
      url: a,
      data: d,
      success: (resp, estado, xhr) => {
        const divcp = eorig.target.closest('.' + AutocompletaAjaxVictimas.claseEnvoltura)
        let r = resp.querySelector('.' + AutocompletaAjaxVictimas.claseEnvoltura)
        divcp.innerHTML=r.innerHTML
        document.dispatchEvent(new Event('sijrscol:autocompletada-victima'))
      },
      error: (resp, estado, xhr) => {
        window.alert('Error con ajax ' + resp)
      }
    })
  }

  static iniciar() {
    if (typeof window.SiSjrAutcompletaAjaxVictimaCargado === 'undefined') {
      console.log('window.SiS no definido')
      window.SiSjrAutcompletaAjaxVictimaCargado === true
    } else {
      console.log('Se carga varias veces????')
      return
    }

    console.log("AutocompletaAjaxVictimas si_jrscol")
    let url = window.puntomontaje + 'personas.json'
    var asistentes = new window.AutocompletaAjaxExpreg(
      [ /^caso_victima_attributes_[0-9]*_persona_attributes_apellidos$/,
        /^caso_victima_attributes_[0-9]*_persona_attributes_numerodocumento$/ ],
      url,
      AutocompletaAjaxVictimas.idDatalist,
      AutocompletaAjaxVictimas.operarElegida
    )
    asistentes.iniciar()
  }

}


