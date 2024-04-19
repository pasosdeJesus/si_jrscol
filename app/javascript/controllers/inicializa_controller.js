import { Controller } from "@hotwired/stimulus"
// Inicializa lo necesario tras cargar página

import TomSelect from 'tom-select';

export default class extends Controller {

  static targets = [ ]

  connect() {
    console.log('conectado controlador inicializa_controller')
    document.querySelectorAll('.tom-select').forEach((el)=>{
      new TomSelect(el, window.configuracionTomSelect);
    });

  }

}
