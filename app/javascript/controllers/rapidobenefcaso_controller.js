import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'
import  RespuestacasoController   from './respuestacaso_controller'

export default class extends Controller {

  static targets = [ 
    'caso'
  ];

  // actividad_id
  // caso_id

  connect() {
    console.log('conectado controlador rapidobenefcaso')
  }

  actualizaListado(d) {
    document.body.style.cursor = "wait"
    let e = d.e
    let url = `/asistencia/rapidobenefcaso?actividad_id=${d.actividad_id}&`+
      `caso_id=${d.caso_id}`
    if (typeof d.persona_ids != "undefined") {
      url += `&persona_ids=${d.persona_ids}`
    }
    window.Rails.ajax({
      type: 'GET',
      url: url,
      data: null,
      success: (resp, estado, xhr) => {
        let b = document.getElementById('boton_actualizar_listado')
        b.click()
        document.body.style.cursor = "wait"
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

  validar(e) {
    if (e.target.getAttribute('disabled') == 'true') {
      alert('Modificación al listado de asistencia en curso, espere por favor')
      return false;
    }
    e.target.setAttribute('disabled', true)
    this.actividad_id = document.getElementById('actividad_id').value
    this.caso_id = this.casoTarget.value

    if (this.caso_id == '') {
      e.target.setAttribute('disabled', false)
      alert('Primero debe elegir un caso')
      return false;
    }
    if (this.caso_id != +this.caso_id) {
      e.target.setAttribute('disabled', false)
      alert("Se espera el número de caso.\n" +
        "Puede buscar por nombre del contacto y cuando lo vea " +
        "elijalo en la lista de autocompletación para que se diligencie " +
        "el número de caso de manera automática")
      return false;
    }
    return true;
  }

  requiereGuardar() {
    let created_at = document.querySelector('input#actividad_created_at').value;
    let updated_at = document.querySelector('input#actividad_updated_at').value;
    let c = new Date(created_at);
    let u = new Date(updated_at);
    let diffechas = Math.abs(c-u);
    let cambios = MsipCalcularCambiosParaBitacora()
    delete cambios['actividad[rapidobenefcaso_id]']
    if ( Object.keys(cambios).length > 0 || diffechas < 1000) {
      return true;
    } else {
      return false;
    }
  }

  agregarTodos(e) {
    if (!this.validar(e)) {
      return
    }

    if ( this.requiereGuardar() ) {
      window.MsipGuardarFormularioYRepintar(
        ['errores'], this.actualizaListado, 
        {actividad_id: this.actividad_id, caso_id: this.caso_id, e: e},
        this.manejaError, e
      )
    } else {
      this.actualizaListado({actividad_id: this.actividad_id, caso_id: this.caso_id, e: e})
    }

  }

  abrirModal(opciones) {
    let e = opciones['e']
    let m = document.getElementById('modal-casoasistencia-algunos')
    window.modal_casoasistencia = new bootstrap.Modal(m)
    window.modal_casoasistencia.show()
  }

  modalAlgunos(e) {
    window.MsipGuardarFormularioYRepintar(
      ['errores', 'modal-casoasistencia-algunos'], 
      this.abrirModal, {e: e})
  }

  algunos(e) {
    let parametrosActividad = JSON.parse(
      e.target.getAttribute('data-parametros')
    )
    // Agregar personas elegidas
    let ra = document.getElementById('modal-casoasistencia-algunos');
    let sep = '';
    parametrosActividad['e'] = e;
    parametrosActividad['persona_ids'] = '';
    ra.querySelectorAll('input[type=checkbox]').forEach((c) => {
      if (c.checked) {
        parametrosActividad['persona_ids'] += 
          `${sep}${c.id.replace("persona-", "")}`;
        sep = ',';
      }
    })
    window.modal_casoasistencia.hide();
    this.actualizaListado(parametrosActividad);
  }

}


