import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // Conecta con data-controller="chequeo-expande"
  // En el botón de chequeo que expandirá:
  //   data-action='change->chequeo-expande#cambiar'
  // En el div por expandir agregar
  //   data-chequeo-expande-target='divexpandir'

  static targets = [ 
    'divexpandir'
  ];

  connect() {
    console.log('conectado controlador chequeo_expande')
  }

  cambiar(e) {
    debugger
    if (e.target.checked) {
      this.divexpandirTarget.classList.remove('collapse')
    } else {
      this.divexpandirTarget.classList.add('collapse')
    }
  }

}


