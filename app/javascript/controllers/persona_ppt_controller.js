import { Controller } from "@hotwired/stimulus"
// Presenta o esconde el campo ppt según lo que se elija en el
// campo ultimoestatusmigratorio

export default class extends Controller {
  // Conecta con data-controller="persona-ppt"
  // En el campo para el último estatus migratorio agregar
  // data-persona-ppt-action='change->persona-ppt#cambia_ultimoestatusmigratorio
  // En el campo del ppt agregar
  // data-persona-ppt-target='ppt'

  static targets = [ 
    "ppt"
  ]

  connect() {
    console.log('conectado controlador persona_ppt_controller')
  }

  cambia_ultimoestatusmigratorio(e) {

    if (e.target.value == '1') {
      this.pptTarget.style.display = 'block'
    } else {
      this.pptTarget.style.display = 'none'
    }

  }

}
