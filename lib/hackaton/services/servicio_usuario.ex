defmodule Hackaton.Services.ServicioUsuario do
  alias Hackaton.Adapter.BaseDatos.BdUsuario
  alias Hackaton.Domain.Usuario
  alias Hackaton.Util.SesionGlobal
  alias Hackaton.Util.{Encriptador, GeneradorID}


  def registrar_usuario(nombre_archivo, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena) do

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
        id = GeneradorID.generar_id_unico(pref, fn nuevo_id ->
          Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.id == nuevo_id end) end)

      nuevo_usuario = Usuario.crear_usuario(id, rol, nombre, apellido, cedula, correo, telefono, usuario, Encriptador.hash_contrasena(contrasena), "")
      BdUsuario.escribir_usuario(nombre_archivo, nuevo_usuario)
      {:ok, nuevo_usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    usuarios = BdUsuario.leer_usuarios(nombre_archivo)

    case Enum.find(usuarios, fn u -> u.usuario == usuario && Encriptador.verificar_contrasena(contrasena, u.contrasena) end) do
      nil -> {:error, "Usuario o contraseña incorrectos."}
      u ->
        SesionGlobal.iniciar_sesion(u)
        {:ok, u}
    end
  end

  def cerrar_sesion() do
    SesionGlobal.cerrar_sesion()
  end

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


  def obtener_todos(nombre_archivo), do: BdUsuario.leer_usuarios(nombre_archivo)


  def obtener_usuario(nombre_archivo, id) do
    usuario = BdUsuario.leer_usuario(nombre_archivo, id)
    if not usuario do
      {:error, "No se pudo encontrar el usuario con ese id"}
    else
      {:ok,usuario}
    end
  end

  def obtener_usuario_user(nombre_archivo, user) do
    usuario = BdUsuario.leer_usuario_user(nombre_archivo, user)
    if not usuario do
      {:error, "No se pudo encontrar el usuario #{user}"}
    else
      {:ok,usuario}
    end
  end

  def obtener_participantes(nombre_archivo), do: BdUsuario.leer_participantes(nombre_archivo)
  def obtener_participantes_equipo(nombre_archivo, id_equipo_buscar) do
     BdUsuario.leer_participantes_equipo(nombre_archivo, id_equipo_buscar)
  end
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
