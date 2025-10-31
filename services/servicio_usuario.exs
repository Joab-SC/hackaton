defmodule Hackaton.Services.ServicioUsuario do
  alias Hackaton.Adapter.BaseDatos.BdUsuario
  alias Hackaton.Domain.Usuario
  alias Hackaton.Util.{Encriptador, GeneradorID}

  # -------------------------
  # REGISTRO DE USUARIO
  # -------------------------
  def registrar_usuario(nombre_archivo, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo) do

    with :ok <- Usuario.validar_campos_obligatorios(rol, nombre, apellido, cedula, correo, usuario, contrasena),
         :ok <- Usuario.validar_rol(rol),
         :ok <- Usuario.validar_correo(correo),
         :ok <- validar_usuario_unico(nombre_archivo, usuario),
         :ok <- validar_cedula_unica(nombre_archivo, cedula) do
         pref = cond do
          rol == "ADMIN" -> "adm"
          rol == "PARTICIPANTE" -> "ptc"
          rol == "MENTOR" -> "mtr"
        end
        id = GeneradorID.unico(pref, fn nuevo_id ->
          Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.id == nuevo_id end) end)

      nuevo_usuario = Usuario.crear_usuario(id, rol, nombre, apellido, cedula, correo, telefono, usuario, Encriptador.hash_contrasena(contrasena), id_equipo)
      BdUsuario.escribir_usuario(nombre_archivo, nuevo_usuario)
      {:ok, nuevo_usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  # -------------------------
  # LOGIN / AUTENTICACIÓN
  # -------------------------
  def autenticar_usuario(nombre_archivo, usuario, contrasena) do
    usuarios = BdUsuario.leer_usuarios(nombre_archivo)

    case Enum.find(usuarios, fn u -> u.usuario == usuario && Encriptador.verificar_contrasena(contrasena, u.contrasena) end) do
      nil -> {:error, "Usuario o contraseña incorrectos."}
      u -> {:ok, u}
    end
  end

  # -------------------------
  # VALIDACIONES DE ENTORNO
  # -------------------------
  defp validar_usuario_unico(nombre_archivo, usuario) do
    if Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.usuario == usuario end) do
      {:error, "El nombre de usuario ya está en uso."}
    else
      :ok
    end
  end

  defp validar_cedula_unica(nombre_archivo, cedula) do
    if Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.cedula == cedula end) do
      {:error, "Ya existe un usuario con esa cédula."}
    else
      :ok
    end
  end


  # -------------------------
  # CONSULTAS Y OPERACIONES
  # -------------------------
  def obtener_todos(nombre_archivo), do: BdUsuario.leer_usuarios(nombre_archivo)
  def obtener_por_id(nombre_archivo, id), do: BdUsuario.leer_usuario(nombre_archivo, id)
  def obtener_participantes(nombre_archivo), do: BdUsuario.leer_participantes(nombre_archivo)
  def obtener_mentores(nombre_archivo), do: BdUsuario.leer_mentores(nombre_archivo)
  def eliminar_usuario(nombre_archivo, id), do: BdUsuario.borrar_usuario(nombre_archivo, id)

  def actualizar_usuario(nombre_archivo, usuario) do
    with :ok <- Usuario.validar_campos_obligatorios(usuario.rol, usuario.nombre, usuario.apellido, usuario.cedula, usuario.correo, usuario.usuario, usuario.contrasena),
         :ok <- Usuario.validar_correo(usuario.correo) do
      BdUsuario.actualizar_usuario(nombre_archivo, usuario)
      {:ok, usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end
end
