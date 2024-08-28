import {
  preparar,
  prepararYAutenticarDeAmbiente,
  terminar
} from "@pasosdeJesus/pruebas_puppeteer"

(async () => {

  const tiempoini = performance.now()

  let timeout = 15000
  let urlini, runner, browser, page
  [urlini, runner, browser, page] = await prepararYAutenticarDeAmbiente(timeout, preparar)

  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Administrar'
      ],
      [
        '#navbarDropdownAdministrar'
      ],
      [
        'xpath///*[@id="navbarDropdownAdministrar"]'
      ],
      [
        'pierce/#navbarDropdownAdministrar'
      ],
      [
        'text/Administrar'
      ]
    ],
    offsetY: 16,
    offsetX: 69,
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Tablas básicas'
      ],
      [
        'ul:nth-of-type(2) > li:nth-of-type(2) li:nth-of-type(5) > a'
      ],
      [
        'xpath///*[@id="navbarSupportedContent"]/ul[2]/li[2]/ul/li[5]/a'
      ],
      [
        'pierce/ul:nth-of-type(2) > li:nth-of-type(2) li:nth-of-type(5) > a'
      ],
      [
        'text/Tablas básicas'
      ]
    ],
    offsetY: 9,
    offsetX: 78,
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Centros poblados'
      ],
      [
        'li:nth-of-type(18) > a'
      ],
      [
        'xpath///*[@id="div_contenido"]/article/ul/li[18]/a'
      ],
      [
        'pierce/li:nth-of-type(18) > a'
      ],
      [
        'text/Centros poblados'
      ]
    ],
    offsetY: 3,
    offsetX: 57.5,
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'form > div:nth-of-type(1) a'
      ],
      [
        'xpath///*[@id="div_contenido"]/form/div[1]/div[1]/a'
      ],
      [
        'pierce/form > div:nth-of-type(1) a'
      ]
    ],
    offsetY: 22,
    offsetX: 54.5,
    assertedEvents: [
      {
        type: 'navigation',
        url: 'nueva',
        title: ''
      }
    ]
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Nombre *'
      ],
      [
        '#centropoblado_nombre'
      ],
      [
        'xpath///*[@id="centropoblado_nombre"]'
      ],
      [
        'pierce/#centropoblado_nombre'
      ]
    ],
    offsetY: 30,
    offsetX: 171.5,
  });
  await runner.runStep({
    type: 'change',
    value: 'x',
    selectors: [
      [
        'aria/Nombre *'
      ],
      [
        '#centropoblado_nombre'
      ],
      [
        'xpath///*[@id="centropoblado_nombre"]'
      ],
      [
        'pierce/#centropoblado_nombre'
      ]
    ],
    target: 'main'
  });
  await runner.runStep({
    type: 'keyDown',
    target: 'main',
    key: 'Tab'
  });
  await runner.runStep({
    type: 'keyUp',
    key: 'Tab',
    target: 'main'
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Abejorral / Antioquia'
      ],
      [
        '#centropoblado_municipio_id-opt-1'
      ],
      [
        'xpath///*[@id="centropoblado_municipio_id-opt-1"]'
      ],
      [
        'pierce/#centropoblado_municipio_id-opt-1'
      ]
    ],
    offsetY: 16,
    offsetX: 117.5,
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Código dentro del municipio'
      ],
      [
        '#centropoblado_cplocal_cod'
      ],
      [
        'xpath///*[@id="centropoblado_cplocal_cod"]'
      ],
      [
        'pierce/#centropoblado_cplocal_cod'
      ]
    ],
    offsetY: 24,
    offsetX: 132.5,
  });
  await runner.runStep({
    type: 'change',
    value: '999',
    selectors: [
      [
        'aria/Código dentro del municipio'
      ],
      [
        '#centropoblado_cplocal_cod'
      ],
      [
        'xpath///*[@id="centropoblado_cplocal_cod"]'
      ],
      [
        'pierce/#centropoblado_cplocal_cod'
      ]
    ],
    target: 'main'
  });
  await runner.runStep({
    type: 'keyDown',
    target: 'main',
    key: 'Tab'
  });
  await runner.runStep({
    type: 'keyUp',
    key: 'Tab',
    target: 'main'
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'body'
      ],
      [
        'xpath//html/body'
      ],
      [
        'pierce/body'
      ]
    ],
    offsetY: 305,
    offsetX: 32,
  });
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Crear'
      ],
      [
        'div.form-actions > input'
      ],
      [
        'xpath///*[@id="new_centropoblado"]/div[11]/input'
      ],
      [
        'pierce/div.form-actions > input'
      ],
      [
        'text/Crear'
      ]
    ],
    offsetY: 25,
    offsetX: 50.5,
    assertedEvents: [
      {
        type: 'navigation',
        url: 'cp',
        title: ''
      }
    ]
  });

  page.on('dialog', async dialog => {
    console.log(dialog.message())
    await dialog.accept(); //o dismiss()
  })
  await runner.runStep({
    type: 'click',
    target: 'main',
    selectors: [
      [
        'aria/Eliminar'
      ],
      [
        'div:nth-of-type(4) > a'
      ],
      [
        'xpath///*[@id="div_contenido"]/div[5]/form/div/div[4]/a'
      ],
      [
        'pierce/div:nth-of-type(4) > a'
      ],
      [
        'text/Eliminar'
      ]
    ],
    offsetY: 18,
    offsetX: 14.5,
  });

  await terminar(runner)

  const tiempofin = performance.now();
  console.log(`Tiempo de ejecución: ${tiempofin - tiempoini} ms`);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
