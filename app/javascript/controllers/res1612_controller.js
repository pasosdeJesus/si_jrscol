import { Controller } from '@hotwired/stimulus'

// Expande/contrae un div colapsable
export default class extends Controller {
  // Conecta con data-controller="chequeo-expande"
  // En el botón de chequeo que expandirá:
  //   data-action='change->chequeo-expande#cambiar'
  // En el div por expandir agregar
  //   data-chequeo-expande-target='divexpandir'

  static targets = [ 
    'divexpandir',
    'botonacto'
  ];

  // Basado en
  // https://stackoverflow.com/questions/1090948/change-url-parameters-and-specify-defaults-using-javascript
  static actualizarParametroPorNombre(url, param, valor) {
    var nuevoURLAdicional = "";
    var arregloTemp = url.split("?");
    var urlBase = arregloTemp[0];
    var urlAdicional = arregloTemp[1];
    var temp = "";
    if (urlAdicional) {
      arregloTemp = urlAdicional.split("&");
      for (var i=0; i<arregloTemp.length; i++){
        if(arregloTemp[i].split('=')[0] != param){
          nuevoURLAdicional += temp + arregloTemp[i];
          temp = "&";
        }
      }
    }

    var rows_txt = temp + "" + param + "=" + valor;
    return urlBase + "?" + nuevoURLAdicional + rows_txt;
  }

  connect() {
    console.log('conectado controlador chequeo_expande')
  }

  cambiar(e) {
    if (e.target.value == 'true') {
      this.divexpandirTarget.classList.remove('collapse')
    } else {
      this.divexpandirTarget.classList.add('collapse')
    }
  }

  actualizar(e) {
    let nhref = this.constructor.actualizarParametroPorNombre(
      this.botonactoTarget.href, 
      e.target.name, e.target.value);
    this.botonactoTarget.href = nhref
  }
}


