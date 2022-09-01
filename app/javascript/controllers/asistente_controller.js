import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ 
    "numerodocumento", 
    "id" 
  ]

  cambia_tdocumento(e) {

    console.log("Hola Stimulus asistente!", this.element)
    console.log("numerodocumento ahora es", this.numerodocumentoTarget.value)
    if (e.target.value == '11' && 
      this.numerodocumentoTarget.value == '') { // SIN DOCUMENTO
      window.Rails.ajax({
        type: 'GET',
        url: '/beneficiarios/identificacionsd?persona_id=' + this.idTarget.value ,
        data: null,
        success: (resp, estado, xhr) => {
          this.numerodocumentoTarget.value = resp;
        },
        error: (req, estado, xhr) => {
          window.alert('No pudo consultar identificación.')
        }
      })
    }

  }

}
