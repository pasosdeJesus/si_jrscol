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

  agregar(e) {
    document.body.style.cursor = 'wait'
    let actividad_id=document.getElementById('actividad_id').value
    let caso_id = this.casoTarget.value
    if (caso_id == '') {
      alert('Primero debe elegir un caso')
      return;
    }
    let url = `/asistencia/rapidobenefcaso?actividad_id=${actividad_id}&`+
      `caso_id=${caso_id}`
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
        window.alert('No se pudo llamar función')
      }
    })
  }

}


