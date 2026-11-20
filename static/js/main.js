
document.addEventListener('DOMContentLoaded', () => {
 
  const toggle = document.getElementById('menuToggle');
  const links = document.getElementById('navLinks');
  if (toggle) toggle.addEventListener('click', () => links.classList.toggle('open'));

  
  setTimeout(() => document.querySelectorAll('.flash').forEach(f => f.remove()), 5000);

  
  const gate = document.getElementById('ageGate');
  let ok = false;
  try { ok = localStorage.getItem('svaaa_mayor') === '1'; } catch (e) {}
  if (gate && !ok) gate.classList.remove('hidden');
  const yes = document.getElementById('ageYes');
  const no = document.getElementById('ageNo');
  if (yes) yes.addEventListener('click', () => {
    try { localStorage.setItem('svaaa_mayor', '1'); } catch (e) {}
    gate.classList.add('hidden');
  });
  if (no) no.addEventListener('click', () => {
    document.getElementById('ageMsg').textContent =
      'Lo sentimos: la venta y consulta de bebidas alcohólicas es solo para mayores de 18 años.';
    yes.classList.add('hidden'); no.classList.add('hidden');
  });

  
  const radios = document.querySelectorAll('input[name=modalidad]');
  const boxDom = document.getElementById('boxDomicilio');
  const envioEl = document.getElementById('envioMonto');
  const totalEl = document.getElementById('totalMonto');
  const base = totalEl ? parseFloat(totalEl.dataset.base) : 0;
  const fmt = n => '$' + n.toLocaleString('es-MX', {minimumFractionDigits: 2, maximumFractionDigits: 2});
  let envio = 0;

  function actualizarTotal() {
    if (!totalEl) return;
    envioEl.textContent = fmt(envio);
    totalEl.textContent = fmt(base + envio);
  }
  function modalidadActual() {
    const r = document.querySelector('input[name=modalidad]:checked');
    return r ? r.value : null;
  }
  function aplicarModalidad() {
    if (!boxDom) return;
    const dom = modalidadActual() === 'domicilio';
    boxDom.classList.toggle('hidden', !dom);
    if (!dom) { envio = 0; actualizarTotal(); } else { validarCP(); }
  }
  radios.forEach(r => r.addEventListener('change', aplicarModalidad));

  const selDir = document.getElementById('direccionSel');
  const nueva = document.getElementById('nuevaDir');
  const cpInput = document.getElementById('cpInput');
  const cobMsg = document.getElementById('cobMsg');

  async function validarCP() {
    if (modalidadActual() !== 'domicilio') return;
    let cp = '';
    if (selDir && selDir.value !== 'nueva') {
      cp = selDir.options[selDir.selectedIndex].dataset.cp;
    } else if (cpInput) {
      cp = cpInput.value.trim();
    }
    if (cp.length !== 5) { cobMsg.className = 'notice'; cobMsg.textContent = 'Ingresa un código postal de 5 dígitos para validar la cobertura.'; return; }
    try {
      const r = await fetch('/api/cobertura?cp=' + encodeURIComponent(cp));
      const d = await r.json();
      if (d.ok) {
        cobMsg.className = 'notice ok';
        cobMsg.textContent = `${d.mensaje} Envío ${fmt(d.costo)} · aprox. ${d.tiempo} min.`;
        envio = d.costo;
      } else {
        cobMsg.className = 'notice bad';
        cobMsg.textContent = d.mensaje; envio = 0;
      }
      actualizarTotal();
    } catch (e) { cobMsg.textContent = 'No se pudo validar la cobertura.'; }
  }
  if (selDir) selDir.addEventListener('change', () => {
    nueva.classList.toggle('hidden', selDir.value !== 'nueva');
    validarCP();
  });
  if (cpInput) cpInput.addEventListener('input', validarCP);
  aplicarModalidad();
});
