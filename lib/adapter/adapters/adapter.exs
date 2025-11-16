defmodule Hackaton.Adapter.Adapters.Adapter do
  alias Hackaton.Services.ServicioHackathon
  alias Hackaton.Util.SesionGlobal

  @comandos_admin [
    :enviar_comunicado,
    :teams,
    :project,
    :crear_sala,
    :registrarse,
    :eliminar_usuario
  ]
  @comandos_usuario [
    :join,
    :entrar_sala,
    :mentores,
    :project,
    :crear_proyecto,
    :agregar_avance,
    :registrarse,
    :cambiar_estado_proyecto,
    :my_team
  ]
  @comandos_mentor [:entrar_sala]
  @comandos_global_base [:chat, :login, :log_out, :ver_comandos]
  @comandos_global Enum.uniq(
    @comandos_global_base ++
    @comandos_admin ++
    @comandos_usuario ++
    @comandos_mentor
  )

  def registrarse(:participante) do
    IO.puts("------ REGISTRANDO PARTICIPANTE------ ")

    nombre =
      IO.gets("Ingrese su nombre: ")
      |> String.trim()

    apellido =
      IO.gets("Ingrese su apellido: ")
      |> String.trim()

    cedula =
      IO.gets("Ingrese su cedula: ")
      |> String.trim()

    correo =
      IO.gets(
        "Ingrese su correo: "
      )
      |> String.trim()

    telefono =
      IO.gets("Ingrese su telefono: ")
      |> String.trim()

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contraseña: ")
      |> String.trim()

    usuario =
      ServicioHackathon.registrar_usuario(
        "usuario.csv",
        "PARTICIPANTE",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      )

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def registrarse(:mentor) do
    IO.puts("------ REGISTRANDO MENTOR------ ")

    nombre =
      IO.gets("Ingrese su nombre: ")
      |> String.trim()

    apellido =
      IO.gets("Ingrese su apellido: ")
      |> String.trim()

    cedula =
      IO.gets("Ingrese su cedula: ")
      |> String.trim()

    correo =
      IO.gets(
        "Ingrese su correo: "
      )
      |> String.trim()

    telefono =
      IO.gets("Ingrese su telefono: ")
      |> String.trim()

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contraseña: ")
      |> String.trim()

    usuario =
      ServicioHackathon.registrar_usuario(
        "usuario.csv",
        "MENTOR",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      )

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def login() do
    IO.puts("------ INICIANDO SESIÓN ------ ")

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contrasena: ")
      |> String.trim()

    usuario = ServicioHackathon.iniciar_sesion("usuario.csv", usuario, contrasena)

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se inició sesion correctamente")
    end
  end

  def crear_proyecto() do
    IO.puts("------ CREANDO PROYECTO ------ ")

    nombre =
      IO.gets("Ingrese el nombre de su proyecto: ")
      |> String.trim()

    descripcion =
      IO.gets("Ingrese la descripcion: ")
      |> String.trim()

    categoria =
      IO.gets("Elija categoria: ")
      |> String.trim()

    nombre_equipo =
      IO.gets("Ingrese el nombre de su equipo: ")
      |> String.trim()

    proyecto =
      ServicioHackathon.crear_proyecto(
        "proyecto.csv",
        "equipo.csv",
        nombre,
        descripcion,
        categoria,
        nombre_equipo
      )

    case proyecto do
      {:error, reason} -> IO.puts(reason)
      {:ok, _proyecto} -> IO.puts("Se creo el proyecto exitosamente")
    end
  end

  def salir_hackaton() do
    usuario =
      ServicioHackathon.eliminar_usuario("usuario.csv", SesionGlobal.usuario_actual().id, :id)

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se salio correctamente de la hackaton")
    end
  end

  def expulsar_usuario(user) do
    usuario = ServicioHackathon.eliminar_usuario("usuario.csv", user, :user)

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se expulsó correctamente de la hackaton")
    end
  end

  def teams() do
    IO.puts("------ Lista de equipos ------")
    equipos = ServicioHackathon.listar_equipos("equipo.csv")

    Enum.each(equipos, fn equipo ->
      IO.puts("#{equipo.nombre} — Tema: #{equipo.tema}")
    end)
  end

  def join(nombre_equipo) do
    ingreso =
      ServicioHackathon.unirse_por_nombre(
        "usuario.csv",
        "equipo.csv",
        SesionGlobal.usuario_actual().id,
        nombre_equipo
      )

    case ingreso do
      {:error, reason} -> IO.puts(reason)
      {:ok, _} -> IO.puts("Se ingresó al equipo correctamente")
    end
  end

  def mentores() do
    mentores = ServicioHackathon.obtener_mentores("usuario.csv")

    Enum.each(mentores, fn m ->
      IO.puts("""
      ----------------------------------------
      Rol:           #{m.rol}
      Nombre:        #{m.nombre} #{m.apellido}
      Cédula:        #{m.cedula}
      Correo:        #{m.correo}
      Teléfono:      #{m.telefono}
      Usuario:       #{m.usuario}
      ----------------------------------------
      """)
    end)
  end

  def log_out do
    ServicioHackathon.cerrar_sesion()
  end

  def ver_comandos() do
    IO.puts("------ COMANDOS DISPONIBLES ------")

    case SesionGlobal.usuario_actual().rol do
      "ADMIN" ->
        Enum.each(@comandos_admin ++ @comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      "PARTICIPANTE" ->
        Enum.each(@comandos_usuario ++ @comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      "MENTOR" ->
        Enum.each(@comandos_mentor ++ @comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      nil ->
        IO.puts("/login")
    end
  end

  def project(nombre) do
    case ServicioHackathon.obtener_proyecto_nombre("proyecto.csv", nombre) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        case ServicioHackathon.obtener_equipo_id("equipo.csv", p.id_equipo) do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, e} ->
            IO.puts("""
            ----------------------------------------
            Nombre:         #{p.nombre}
            Descripción:    #{p.descripcion}
            Categoría:      #{p.categoria}
            Estado:         #{p.estado}
            Equipo:         #{e.nombre}
            Tema:           #{e.tema}
            Fecha creación: #{p.fecha_creacion}
            ----------------------------------------
            """)
        end
    end
  end


  def my_team() do
    equipo =
      ServicioHackathon.obtener_equipo_id("equipo.csv", SesionGlobal.usuario_actual().id_equipo)

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, e} -> IO.puts("#{e.nombre} — Tema: #{e.tema}")
    end
  end

  def cambiar_estado_proyecto() do
    nuevo_estado =
      IO.gets("Ingrese el nuevo estado (proceso finalizado): ")
      |> String.trim()

    actualizado = ServicioHackathon.actualizar_estado_proyecto("proyecto.csv", nuevo_estado)

    case actualizado do
      {:error, reason} -> IO.puts(reason)
      {:ok, _proyecto} -> IO.puts("Se actualizó el estado del proyecto correctamente")
    end
  end

  # def ejecutar(comando, rol, args) do
  #   case rol do
  #     cond do
  #        ->
  #     end
  #   end
  # end
end
