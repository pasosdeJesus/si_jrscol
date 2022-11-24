export default class AutocompletaAjaxRapidobenefcaso {


  // Elije un caso en auto-completación
  static operarElegida (eorig, cadgrupo, id, otrosop) {
  }

  static iniciar() {
    console.log("AutocompletaAjaxRapidobenefcaso")
      let url = '/casos/busca.json'
      var aeCasos = new window.AutocompletaAjaxExpreg(
          [ /^actividad_rapidobenefcaso_id$/],
          url,
          AutocompletaAjaxRapidobenefcaso.idDatalist,
          AutocompletaAjaxRapidobenefcaso.operarElegida
          )
      aeCasos.iniciar()
  }

}


AutocompletaAjaxRapidobenefcaso.claseEnvoltura = 'nested-fields';
AutocompletaAjaxRapidobenefcaso.idDatalist = 'fuente-listadocasos';
