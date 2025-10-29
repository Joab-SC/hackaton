defmodule ServicioUsuario do
  alias Bd_Usuario
  alias Usuario

  # -------------------------
  # REGISTRO DE USUARIO
  # -------------------------
  def registrar_usuario(nombre_archivo, id, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo) do
    with :ok <- Usuario.validar_campos_obligatorios(rol, nombre, apellido, cedula, correo, usuario, contrasena),
         :ok <- Usuario.validar_rol(rol),
         :ok <- Usuario.validar_correo(correo),
         :ok <- validar_usuario_unico(nombre_archivo, usuario),
         :ok <- validar_cedula_unica(nombre_archivo, cedula) do

      nuevo_usuario = Usuario.crear_usuario(id, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo)
      Bd_Usuario.escribir_usuario(nombre_archivo, nuevo_usuario)
      {:ok, nuevo_usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  # -------------------------
  # LOGIN / AUTENTICACIÓN
  # -------------------------
  def autenticar_usuario(nombre_archivo, usuario, contrasena) do
    usuarios = Bd_Usuario.leer_usuarios(nombre_archivo)

    case Enum.find(usuarios, fn u -> u.usuario == usuario && u.contrasena == contrasena end) do
      nil -> {:error, "Usuario o contraseña incorrectos."}
      u -> {:ok, u}
    end
  end

  # -------------------------
  # VALIDACIONES DE ENTORNO
  # -------------------------
  defp validar_usuario_unico(nombre_archivo, usuario) do
    if Enum.any?(Bd_Usuario.leer_usuarios(nombre_archivo), fn u -> u.usuario == usuario end) do
      {:error, "El nombre de usuario ya está en uso."}
    else
      :ok
    end
  end

  defp validar_cedula_unica(nombre_archivo, cedula) do
    if Enum.any?(Bd_Usuario.leer_usuarios(nombre_archivo), fn u -> u.cedula == cedula end) do
      {:error, "Ya existe un usuario con esa cédula."}
    else
      :ok
    end
  end

  defp validar_cedula_unica(nombre_archivo, id) do
    if Enum.any?(Bd_Usuario.leer_usuarios(nombre_archivo), fn u -> u.id == id end) do
      {:error, "Ya existe un usuario con este id."}
    else
      :ok
    end
  end

  # -------------------------
  # CONSULTAS Y OPERACIONES
  # -------------------------
  def obtener_todos(nombre_archivo), do: Bd_Usuario.leer_usuarios(nombre_archivo)
  def obtener_por_id(nombre_archivo, id), do: Bd_Usuario.leer_usuario(nombre_archivo, id)
  def obtener_participantes(nombre_archivo), do: Bd_Usuario.leer_participantes(nombre_archivo)
  def obtener_mentores(nombre_archivo), do: Bd_Usuario.leer_mentores(nombre_archivo)
  def eliminar_usuario(nombre_archivo, id), do: Bd_Usuario.borrar_usuario(nombre_archivo, id)

  def actualizar_usuario(nombre_archivo, usuario) do
    with :ok <- Usuario.validar_campos_obligatorios(usuario.rol, usuario.nombre, usuario.apellido, usuario.cedula, usuario.correo, usuario.usuario, usuario.contrasena),
         :ok <- Usuario.validar_correo(usuario.correo) do
      Bd_Usuario.actualizar_usuario(nombre_archivo, usuario)
      {:ok, usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end
end
