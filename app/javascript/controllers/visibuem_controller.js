import { Controller } from "@hotwired/stimulus"
// Presenta o esconde el campo ultimoestatusmigratorio según lo que se elija 
// en el campo ultimoperfil

export default class extends Controller {
  // Conecta con data-controller="visibuem"
  // En el campo para el último pérfil agregar
  // data-visibuem-action='change->visibuem#cambia_ultimoperfil
  // En el campo del ultimoestatusmigratorio agregar
  // data-visibuem-target='uem'

  static targets = [ 
    "uem"
  ]

  connect() {
    console.log('conectado controlador visibuem')
  }

  cambiarUltimoperfil(e) {
    if (e.target.value == '10' || e.target.value == '11' || 
      e.target.value == '12') {
      this.uemTarget.style.display = 'block'
    } else {
      this.uemTarget.style.display = 'none'
    }
  }

}
