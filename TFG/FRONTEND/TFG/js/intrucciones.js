document.addEventListener("DOMContentLoaded", () => {
  const btnMostrar = document.getElementById("btnMostrarInstrucciones");
  const divInstrucciones = document.getElementById("instArch");
  const divArchivos = document.getElementById("listaArchivos");

  // Toggle instrucciones
  btnMostrar.addEventListener("click", () => {
    if (divInstrucciones.style.display === "none" || divInstrucciones.style.display === "") {
      divInstrucciones.style.display = "block";
      btnMostrar.textContent = "Ocultar instrucciones";
    } else {
      divInstrucciones.style.display = "none";
      btnMostrar.textContent = "Mostrar instrucciones";
    }
  });

  // Función para cargar archivos desde backend
  function cargarArchivos() {
    fetch("../../../backend/tfg/api/archivos_usuario.php") // Cambia por la ruta real en backend
      .then(res => res.json())
      .then(data => {
        if (data.archivos && data.archivos.length > 0) {
          divArchivos.innerHTML = "<h3>Archivos disponibles</h3><ul>" + 
            data.archivos.map(archivo => `<li><a href="${archivo.url}" target="_blank">${archivo.nombre}</a></li>`).join('') +
            "</ul>";
        } else {
          divArchivos.innerHTML = "<p>No hay archivos disponibles.</p>";
        }
      })
      .catch(() => {
        divArchivos.innerHTML = "<p>Error cargando archivos.</p>";
      });
  }

  cargarArchivos();
});
