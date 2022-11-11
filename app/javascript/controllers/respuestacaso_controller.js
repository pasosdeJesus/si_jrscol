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

  /*
   * Con AJAX actualiza formulario, espera recibir formulario guardado
   * para repintar áreas identificadas con listaIdsRepintar y llamar
   * la retrollamada.
   *
   * Se espera que en rails la función update, maneje request.xhr?
   * para no ir a hacer redirect_to con lo proveniente de un XHR 
   * (ver ejemplo en app/controllers/sivel2_sjr/casos_controller.rb)
   *
   * @param listaIdsRepintar Lista de ids de elementos por repintar
   *   Si hay uno llamado errores no vacio después de pintar detiene
   *   con mensaje de error.
   * @param retrollamada Función por llamar en caso de éxito
   * @parama argumento Por pasar a la función retrollamada (se sugiere
   *  que sea un registro).
   */
  static guardarFormularioYRepintar(listaIdsRepintar, retrollamada, argumentos) {
    document.body.style.cursor = 'wait'
    let formulario = document.querySelector('form')
    if (formulario == null) {
      alert('** respuestacaso: No se encontró formulario')
    }
    let datos = new FormData(formulario);
    datos.set('commit', 'Enviar')
    datos.set('siguiente', 'editar')
    let paramUrl = new URLSearchParams(datos).toString()
    document.getElementById('errores').innerText=''
    window.Rails.ajax({
      type: 'PATCH',
      url: formulario.getAttribute('action'),
      data: datos,
      success: (resp, estado, xhr) => {
        document.body.style.cursor = 'default'
        let hayErrores = false
        listaIdsRepintar.forEach((idfrag) => {
          let f = document.getElementById(idfrag)
          let nf = resp.getElementById(idfrag)
          if (nf) {
            f.innerHTML = nf.innerHTML
            if (idfrag === 'errores' && nf.innerHTML.trim() !== '') {
              hayErrores = true
            }
          }
        })
        if (hayErrores) {
          alert('Hay errores que no permiten guardar el caso y crear la actividad')
          return
        }
        retrollamada(argumentos)
      },
      error: (req, estado, xhr) => {
        document.body.style.cursor = 'default'
        window.alert('No se pudo guardar formulario.')
      }
    })
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
    this.constructor.guardarFormularioYRepintar(
      ['errores'], this.crearActividad, {urlActividad: urlActividad}) 
  }


  abrirModal(opciones) {
    let m = document.getElementById('modal-respuesta-algunos')
    let modal = new bootstrap.Modal(m)
    modal.show()
  }


  modalAlgunos(e) {
    this.guardarFormularioYRepintar(['errores', 'modal-respuesta-algunos'], 
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
