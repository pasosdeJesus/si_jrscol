import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'
import  RespuestacasoController   from './respuestacaso_controller'

export default class extends Controller {

  static targets = [ 
    'caso'
  ]

  connect() {
    console.log('conectado controlador rapidobenefcaso')
  }

  actualizaListado(d) {
    let url = `/asistencia/rapidobenefcaso?actividad_id=${d.actividad_id}&`+
      `caso_id=${d.caso_id}`
    window.Rails.ajax({
      type: 'GET',
      url: url,
      data:null,
      success: (resp, estado, xhr) => {
        let b = document.getElementById('boton_actualizar_listado')
        b.click()
        // Lo hace escuchador de evento turbo:frame-load document.body.style.cursor = 'default'
      },
      error: (req, estado, xhr) => {
        document.body.style.cursor = 'default'
        e.target.setAttribute('disabled', false)
        window.alert("Antes debe elegir uno de los casos que se " +
          "ven en la lista desplegable de autocompletación cuando ha " +
          "digitado más de 4 caracteres")
      }
    })
  }

  manejaError(e) {
    e.target.setAttribute('disabled', false)
  }

  agregar(e) {
    if (e.target.getAttribute('disabled') == 'true') {
      alert('Modificación al listado de asistencia en curso, espere por favor')
      return;
    }
    //document.body.style.cursor = 'wait'
    e.target.setAttribute('disabled', true)
    let actividad_id = document.getElementById('actividad_id').value
    let caso_id = this.casoTarget.value
    if (caso_id == '') {
      //document.body.style.cursor = 'default'
      e.target.setAttribute('disabled', false)
      alert('Primero debe elegir un caso')
      return;
    }
    if (caso_id != +caso_id) {
      //document.body.style.cursor = 'default'
      e.target.setAttribute('disabled', false)
      alert("Se espera el número de caso.\n" +
        "Puede buscar por nombre del contacto y cuando lo vea " +
        "elijalo en la lista de autocompletación para que se diligencie " +
        "el número de caso de manera automática")
      return;
    }
    window.SipGuardarFormularioYRepintar(
      ['errores'], this.actualizaListado, 
      {actividad_id: actividad_id, caso_id: caso_id},
      this.manejaError, e
    )
  }

}


