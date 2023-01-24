import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {

  static targets = [ 
    'lineas',
    'proyectofinanciero_id'
  ]

  connect() {
    console.log('conectado controlador respuestacaso')
  }

  crearActividad(opciones) {
    window.open(opciones.urlActividad, '_blank').focus();
  }

  armarUrlActividad1(parametrosActividad) {
    let t = this.targets

    let urlActividad = window.puntomontaje + 'actividades/nueva'
    let sep = '?'

    Object.keys(parametrosActividad).forEach( (l) => {
      urlActividad += `${sep}${l}=${parametrosActividad[l]}`
      sep = '&'
    })

    let proyectofinanciero_id = this.proyectofinanciero_idTarget.value
    if (proyectofinanciero_id != '') {
      urlActividad += `${sep}nsegresp_proyectofinanciero_id=${proyectofinanciero_id}`
      sep = '&'
    }

    this.lineasTarget.querySelectorAll('[data-respuestacaso-target]').
      forEach((n)=>{
        let nt = n.getAttribute('data-respuestacaso-target')
        console.log(nt)
        if (t.find(nt).checked) {
          urlActividad += `${sep}${nt.substr(6)}=true` // quitamos linea-
          sep = '&'
        }
      })

    return urlActividad
  }


  todos(e) {
    let parametrosActividad = JSON.parse(
      e.target.getAttribute('data-parametros')
    )
    let urlActividad = this.armarUrlActividad1(parametrosActividad)
    window.MsipGuardarFormularioYRepintar(
      ['errores'], this.crearActividad, {urlActividad: urlActividad}) 
  }


  abrirModal(opciones) {
    let m = document.getElementById('modal-respuesta-algunos')
    let modal = new bootstrap.Modal(m)
    modal.show()
  }


  modalAlgunos(e) {
    window.MsipGuardarFormularioYRepintar(
      ['errores', 'modal-respuesta-algunos'], 
      this.abrirModal, {})
  }


  algunos(e) {
    let parametrosActividad = JSON.parse(
      e.target.getAttribute('data-parametros')
    )
    let urlActividad = this.armarUrlActividad1(parametrosActividad)
    // Reemplazar personas por las guardadas
    let ra = document.getElementById('modal-respuesta-algunos')
    let sep = '&'
    ra.querySelectorAll('input[type=checkbox]').forEach((c) => {
      if (c.checked) {
        urlActividad += `${sep}${c.id}=true`
      }
    })
    console.log('urlActividad=' + urlActividad)
    this.crearActividad({urlActividad: urlActividad})
  }

}
