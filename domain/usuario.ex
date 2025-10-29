defmodule Usuario do
  defstruct id: "",
            rol: "",
            nombre: "",
            apellido: "",
            cedula: "",
            correo: "",
            teléfono: "",
            usuario: "",
            contrasena: "",
            id_equipo: ""

  def crear_usuario(
        id,
        rol,
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena,
        id_equipo
      ) do
    %Usuario{
      id: id,
      rol: rol,
      nombre: nombre,
      apellido: apellido,
      cedula: cedula,
      correo: correo,
      teléfono: telefono,
      usuario: usuario,
      contrasena: contrasena,
      id_equipo: id_equipo
    }
  end

  def validar_campos_obligatorios(rol, nombre, apellido, cedula, correo, usuario, contrasena) do
    if Enum.any?([rol, nombre, apellido, cedula, correo, usuario, contrasena], &(&1 in ["", nil])) do
      {:error, "Todos los campos obligatorios deben estar llenos."}
    else
      :ok
    end
  end

  def validar_rol(rol) do
    if rol in ["PARTICIPANTE", "MENTOR", "ADMIN"] do
      :ok
    else
      {:error, "Rol no válido. Debe ser PARTICIPANTE, MENTOR o ADMIN."}
    end
  end

  def validar_correo(correo) do
    if Regex.match?(~r/^[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,4}$/, correo) do
      :ok
    else
      {:error, "El correo electrónico no tiene un formato válido."}
    end
  end

  # Validaciones de unicidad se delegan al servicio (porque necesitan acceder al entorno/persistencia)
end
