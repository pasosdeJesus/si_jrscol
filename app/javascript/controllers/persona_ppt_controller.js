import { Controller } from "@hotwired/stimulus"
// Presenta o esconde el campo ppt según lo que se elija en el
// campo ultimoestatusmigratorio

export default class extends Controller {
  // Conecta con data-controller="persona-ppt"
  // En el campo para el último estatus migratorio agregar
  // data-action="change->persona-ppt#cambia_ultimoestatusmigratorio"
  // En el campo del ppt agregar
  // data-persona-ppt-target="ppt"

  static targets = [ 
    "ppt",
    "tdocumentoId",
    "numerodocumento"
  ]

  connect() {
    console.log('conectado controlador persona_ppt_controller')
  }

  cambia_numerodocumento(e) {
    if (this.tdocumentoIdTarget.value == 16) { //PPT 
      this.pptTarget.value = this.numerodocumentoTarget.value
    }
  }

  cambia_ppt(e) {
    if (this.tdocumentoIdTarget.value == 16) { //PPT 
      this.numerodocumentoTarget.value = this.pptTarget.value 
    }
  }

  cambia_tdocumento(e) {
    if (e.target.value == 16) { //PPT 
      if (this.pptTarget.value != '') {
        this.numerodocumentoTarget.value = this.pptTarget.value 
      }
    }
  }

  cambia_ultimoestatusmigratorio(e) {

    if (e.target.value == '1') {
      this.pptTarget.parentNode.style.display = 'block'
    } else {
      this.pptTarget.parentNode.style.display = 'none'
    }

  }

}
