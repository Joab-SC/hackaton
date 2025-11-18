defmodule Hackaton.Services.ServicioUsuario do
  @moduledoc """
  Servicio encargado de gestionar toda la lógica relacionada con usuarios:
  registro, autenticación, validaciones de unicidad, consultas, actualización
  y eliminación.

  """

  alias Hackaton.Adapter.BaseDatos.BdUsuario
  alias Hackaton.Domain.Usuario
  alias Hackaton.Util.{Encriptador, GeneradorID}

  @doc """
  Registra un nuevo usuario en el sistema tras validar:

    - Campos obligatorios
    - Nombre de usuario único
    - Cédula única

  Se genera un ID único basado en el rol del usuario:
    - ADMIN → `"adm"`
    - PARTICIPANTE → `"ptc"`
    - MENTOR → `"mtr"`

  La contraseña se almacena **encriptada** mediante `Encriptador.hash_contrasena/1`.

  """
  def registrar_usuario(
        nombre_archivo,
        rol,
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ) do
    with :ok <-
           Usuario.validar_campos_obligatorios(
             rol,
             nombre,
             apellido,
             cedula,
             correo,
             telefono,
             usuario,
             contrasena
           ),
         :ok <- validar_usuario_unico(nombre_archivo, usuario),
         :ok <- validar_cedula_unica(nombre_archivo, cedula) do
      pref =
        cond do
          rol == "ADMIN" -> "adm"
          rol == "PARTICIPANTE" -> "ptc"
          rol == "MENTOR" -> "mtr"
        end

      id =
        GeneradorID.generar_id_unico(pref, fn nuevo_id ->
          Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.id == nuevo_id end)
        end)

      nuevo_usuario =
        Usuario.crear_usuario(
          id,
          rol,
          nombre,
          apellido,
          cedula,
          correo,
          telefono,
          usuario,
          Encriptador.hash_contrasena(contrasena),
          ""
        )

      BdUsuario.escribir_usuario(nombre_archivo, nuevo_usuario)
      {:ok, nuevo_usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  @doc """
  Inicia sesión validando:

    - Que el usuario exista
    - Que la contraseña coincida (comparación encriptada)

  """
  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    usuarios = BdUsuario.leer_usuarios(nombre_archivo)

    case Enum.find(usuarios, fn u ->
           u.usuario == usuario && Encriptador.verificar_contrasena(contrasena, u.contrasena)
         end) do
      nil ->
        {:error, "Usuario o contraseña incorrectos."}

      u ->
        {:ok, u}
    end
  end

  @doc """
  Verifica que el nombre de usuario no esté registrado previamente.
  """
  defp validar_usuario_unico(nombre_archivo, usuario) do
    if Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.usuario == usuario end) do
      {:error, "El nombre de usuario ya está en uso."}
    else
      :ok
    end
  end

  @doc """
  Valida que la cédula no esté registrada en otro usuario.

  """
  defp validar_cedula_unica(nombre_archivo, cedula) do
    if Enum.any?(BdUsuario.leer_usuarios(nombre_archivo), fn u -> u.cedula == cedula end) do
      {:error, "Ya existe un usuario con esa cédula."}
    else
      :ok
    end
  end

  @doc """
  Retorna todos los usuarios almacenados en el archivo.
  """
  def obtener_todos(nombre_archivo), do: BdUsuario.leer_usuarios(nombre_archivo)

  @doc """
  Obtiene un usuario por ID.

  """
  def obtener_usuario(nombre_archivo, id) do
    usuario = BdUsuario.leer_usuario(nombre_archivo, id)

    if is_nil(usuario) do
      {:error, "No se pudo encontrar el usuario con ese id"}
    else
      {:ok, usuario}
    end
  end

  @doc """
  Obtiene un usuario por su nombre de usuario (`user`).

  """
  def obtener_usuario_user(nombre_archivo, user) do
    usuario = BdUsuario.leer_usuario_user(nombre_archivo, user)

    if is_nil(usuario) do
      {:error, "No se pudo encontrar el usuario #{user}"}
    else
      {:ok, usuario}
    end
  end

  @doc """
  Obtiene todos los usuarios cuyo rol es PARTICIPANTE.
  """
  def obtener_participantes(nombre_archivo), do: BdUsuario.leer_participantes(nombre_archivo)

  @doc """
  Obtiene participantes que pertenecen a un equipo específico.
  """
  def obtener_participantes_equipo(nombre_archivo, id_equipo_buscar) do
    case BdUsuario.leer_participantes_equipo(nombre_archivo, id_equipo_buscar) do
      [] -> {:error, "No hay participantes en este equipo"}
      participantes -> {:ok, participantes}
    end
  end

  @doc """
  Devuelve todos los usuarios cuyo rol es MENTOR.
  """
  def obtener_mentores(nombre_archivo), do: BdUsuario.leer_mentores(nombre_archivo)

  @doc """
  Elimina un usuario por su ID.
  """
  def eliminar_usuario(nombre_archivo, id), do: BdUsuario.borrar_usuario(nombre_archivo, id)

  @doc """
  Actualiza un usuario completo después de validar:

    - Campos obligatorios
    - Correo válido

  """
  def actualizar_usuario(nombre_archivo, usuario) do
    with :ok <-
           Usuario.validar_campos_obligatorios(
             usuario.rol,
             usuario.nombre,
             usuario.apellido,
             usuario.cedula,
             usuario.correo,
             usuario.telefono,
             usuario.usuario,
             usuario.contrasena
           ),
         {:ok, _} <- Usuario.validar_correo(usuario.correo) do
      BdUsuario.actualizar_usuario(nombre_archivo, usuario)
      {:ok, usuario}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  @doc """
  Actualiza un solo campo de un usuario dinámicamente.

  Flujo:
    1. Verifica que el usuario exista.
    2. Valida que el campo a modificar es permitido.
    3. Aplica el cambio usando `Map.put/3`.
    4. Ejecuta `actualizar_usuario/2`.

  """
  def actualizar_campo(nombre_archivo, id_usuario, valor, tipo_campo) do
    case {obtener_usuario(nombre_archivo, id_usuario), Usuario.campo_valido(tipo_campo)} do
      {{:ok, usuario}, {:ok, tipo_campo}} ->
        actualizado = Map.put(usuario, tipo_campo, valor)
        actualizar_usuario(nombre_archivo, actualizado)

      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}
    end
  end
end
