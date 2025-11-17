defmodule Hackaton.Domain.Usuario do
  @roles ["PARTICIPANTE", "MENTOR", "ADMIN"]
  @campos [:rol, :nombre, :apellido, :cedula, :correo, :telefono, :usuario, :contrasena]
  defstruct id: "",
            rol: "",
            nombre: "",
            apellido: "",
            cedula: "",
            correo: "",
            telefono: "",
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
    %__MODULE__{
      id: id,
      rol: rol,
      nombre: nombre,
      apellido: apellido,
      cedula: cedula,
      correo: correo,
      telefono: telefono,
      usuario: usuario,
      contrasena: contrasena,
      id_equipo: id_equipo
    }
  end

  def validar_campos_vacios(rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena) do
    if Enum.any?([rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena], fn campo ->
      elem(validar_campo_vacio(campo), 0) == :error end) do
      {:error, "Todos los campos obligatorios deben estar llenos."}
    else
      :ok
    end
  end

  def validar_campo_vacio(campo) do
    campo_validar = if is_nil(campo), do: nil, else: String.trim(campo)
    if campo_validar in ["", nil] do
      {:error, "El campo #{campo} no puede estar vacío."}
    else
      {:ok, campo}
    end
  end

  def validar_telefono(telefono) do
     if Regex.match?(~r/^3[0-5][0-9]{8}$/, telefono) do
      {:ok, telefono}
    else
      {:error, "El numero de telefono debe iniciar en 3 y tener 10 digitos"}
    end

  end

  def validar_rol(rol) do
    if rol in @roles do
      {:ok, rol}
    else
      {:error, "Rol no válido. Debe ser PARTICIPANTE, MENTOR o ADMIN."}
    end
  end

  def validar_correo(correo) do
    if Regex.match?(~r/^[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,4}$/, correo) do
      {:ok, correo}
    else
      {:error, "El correo electrónico no tiene un formato válido."}
    end
  end

  def validar_campos_obligatorios(rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena) do
    case validar_campos_vacios(rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena) do
      {:error, reason} -> {:error, reason}
      :ok ->
        case validar_rol(rol) do
          {:error, reason} -> {:error, reason}
          {:ok, _} ->
            case validar_correo(correo) do
              {:error, reason} -> {:error, reason}
              {:ok, _} -> :ok
            end
        end
    end
  end

  def campo_valido(campo) do
    if campo in @campos do
      {:ok, campo}
    else
      {:error, "No existe ningun campo llamado #{campo}"}
    end
  end

  # Validaciones de unicidad se delegan al servicio (porque necesitan acceder al entorno/persistencia)
end
