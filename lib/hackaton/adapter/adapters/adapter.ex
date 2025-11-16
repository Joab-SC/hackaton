defmodule Hackaton.Adapter.Adapters.Adapter do
  alias Hackaton.Services.ServicioHackathon
  alias Hackaton.Util.SesionGlobal
  alias Hackaton.Comunicacion.NodoCliente

  @comandos_admin [
    :enviar_comunicado,
    :teams,
    :project,
    :crear_sala,
    :registrarse,
    :eliminar_usuario
  ]
  @comandos_participante [
    :join,
    :entrar_sala,
    :mentores,
    :project,
    :crear_proyecto,
    :agregar_avance,
    :registrarse,
    :cambiar_estado_proyecto,
    :my_team,
    :registrar_equipo
  ]
  @comandos_mentor [:entrar_sala]
  @comandos_global_base [:chat, :login, :log_out, :ver_comandos, :registrarse]
  @comandos_global Enum.uniq(
    @comandos_global_base ++
    @comandos_admin ++
    @comandos_participante ++
    @comandos_mentor
  )

  def registrarse(:admin) do
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
      NodoCliente.ejecutar(:registrar_usuario, [ "lib/hackaton/adapter/persistencia/usuario.csv",
        "PARTICIPANTE",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end


  def registrarse(_) do
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
      NodoCliente.ejecutar(:registrar_usuario, [ "lib/hackaton/adapter/persistencia/usuario.csv",
        "PARTICIPANTE",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena])
    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end


  def login(_) do
    IO.puts("------ INICIANDO SESIÓN ------ ")

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contrasena: ")
      |> String.trim()

    usuario = NodoCliente.ejecutar(:iniciar_sesion, [ "lib/hackaton/adapter/persistencia/usuario.csv", usuario, contrasena])


    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, u} ->
        SesionGlobal.iniciar_sesion(u)
        IO.puts("Se inició sesion correctamente")
    end
  end

  def registrar_equipo(:participante) do
    IO.puts("------ REGISTRANDO EQUIPO ------ ")

    nombre =
      IO.gets("Ingrese el nombre del equipo: ")
      |> String.trim()

    tema =
      IO.gets("Ingrese el tema del equipo: ")
      |> String.trim()

    equipo =
      NodoCliente.ejecutar(:registrar_equipo, [ "lib/hackaton/adapter/persistencia/equipo.csv", nombre, tema])

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, _equipo} -> IO.puts("Se registró el equipo correctamente")
    end
  end

  def crear_proyecto(:participante) do
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

  def salir_hackaton(:participante) do
    usuario =
      ServicioHackathon.eliminar_usuario("usuario.csv", SesionGlobal.usuario_actual().id, :id)

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se salio correctamente de la hackaton")
    end
  end

  def expulsar_usuario(:admin, user) do
    usuario = ServicioHackathon.eliminar_usuario("usuario.csv", user, :user)

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se expulsó correctamente de la hackaton")
    end
  end

  def teams(:admin) do
    IO.puts("------ Lista de equipos ------")
    equipos = ServicioHackathon.listar_equipos("equipo.csv")

    Enum.each(equipos, fn equipo ->
      IO.puts("#{equipo.nombre} — Tema: #{equipo.tema}")
    end)
  end

  def join(:participante, nombre_equipo) do
    ingreso =

      NodoCliente.ejecutar(:unirse_por_nombre, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "lib/hackaton/adapter/persistencia/equipo.csv",
        SesionGlobal.usuario_actual().id,
        nombre_equipo
      ])



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




#   # El atomo aridad es una idea, para que no se
# explote con funciones como registrarse y coja el atomo de la aridad de jhangod
# eso sí, tocaria ponerle el atomo a todas las funciones
# por ejepmlo:,
    #
    # project (:participante),
    # crear_proyecto(:participante),
    # enviar_comunicado(:admin)
#de modo que todas las funciones de este archivo adapter, inicien con el atomo del rol que la puede ejecutar,
# en caso de una funcion que hayan varios roles que la puedan ejecutar puedes decir tipo
# login(_), porque es indiferente del rol (el _ seria par funciones que los 3 puedan usar)
# para alguna donde hayan 2 roles que la puedan usar lo puedes hacer con guardas entonces
# de todos modos la validacion de los comandos disponibles ya esta en este metodo pero lo de la aridad con el atomo
# seria par solucionar lo de funciones como registrarse
# pd: te amo te quiero besar



def escuchar_comandos() do
  IO.write("> ")

  case IO.gets("") do
    :eof ->
      IO.puts("Saliendo...")
      :ok

    input ->
      input
      |> String.trim()
      |> procesar_entrada()

      escuchar_comandos()
  end
end

defp procesar_entrada(""), do: :ok

defp procesar_entrada("/" <> resto) do
  partes = String.split(resto, " ")

  comando =
    partes
    |> List.first()
    |> String.to_atom()

  args =
    partes
    |> tl()

  ejecutar_comando(comando, args)
end

defp procesar_entrada(_otro) do
  IO.puts("Por favor escriba un comando válido que empiece con /")
end


  def ejecutar_comando(comando, args) do
    if comando not in @comandos_global do
      IO.puts("El comando ingresado no existe")
    else
      usuario = SesionGlobal.usuario_actual()
      rol = if usuario == nil, do: nil, else: usuario.rol

      {comandos_disponibles, atomo_aridad} =
        case rol do
          "PARTICIPANTE" -> {@comandos_participante, :participante}
          "ADMIN" -> {@comandos_admin, :admin}
          "MENTOR" -> {@comandos_mentor, :mentor}
          nil -> {@comandos_global_base, :nada}
          _ -> {[], :nada}
        end

      if comando in comandos_disponibles do
        apply(__MODULE__, comando, [atomo_aridad | args])
      else
        IO.puts("El comando #{comando} no está disponible para el rol #{rol}")
      end
    end
  end

end
