defmodule Hackaton.Adapter.Adapters.Adapter do
  alias Hackaton.Util.SesionGlobal
  alias Hackaton.Comunicacion.NodoCliente
  alias Hackaton.Adapter.Comandos

  def registrar_mentor(:admin) do
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
      IO.gets("Ingrese su correo: ")
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
      NodoCliente.ejecutar(:registrar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "MENTOR",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def registrarse(:incognito) do
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
      IO.gets("Ingrese su correo: ")
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
      NodoCliente.ejecutar(:registrar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "PARTICIPANTE",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def login(:incognito) do
    IO.puts("------ INICIANDO SESIÓN ------ ")

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contrasena: ")
      |> String.trim()

    usuario =
      NodoCliente.ejecutar(:iniciar_sesion, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} ->
        IO.puts(reason)

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
      NodoCliente.ejecutar(:registrar_equipo, [
        "lib/hackaton/adapter/persistencia/equipo.csv",
        nombre,
        tema
      ])

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, _equipo} -> IO.puts("Se registró el equipo correctamente")
    end
  end

  def crear_proyecto(:participante) do
    usuario = SesionGlobal.usuario_actual()

    if usuario.id_equipo == "" do
      IO.puts(
        "No puedes crear un proyecto si no perteneces a un equipo. Únete o crea un equipo primero."
      )
    else
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

      id_equipo = usuario.id_equipo

      proyecto =
        NodoCliente.ejecutar(:crear_proyecto, [
          "lib/hackaton/adapter/persistencia/proyecto.csv",
          nombre,
          descripcion,
          categoria,
          id_equipo
        ])

      case proyecto do
        {:error, reason} ->
          IO.puts(reason)

        {:ok, _proyecto} ->
          IO.puts("Se creo el proyecto exitosamente")
      end
    end
  end

  def salir_hackaton(:participante) do
    usuario =
      NodoCliente.ejecutar(:eliminar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        SesionGlobal.usuario_actual().id,
        :id
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se salio correctamente de la hackaton")
    end
  end

  def expulsar_usuario(:admin, user) do
    usuario =
      NodoCliente.ejecutar(:eliminar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        user,
        :user
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se expulsó correctamente de la hackaton")
    end
  end

  def teams(:admin) do
    IO.puts("------ Lista de equipos ------")

    equipos =
      NodoCliente.ejecutar(:listar_equipos, ["lib/hackaton/adapter/persistencia/equipo.csv"])

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
      {:error, reason} ->
        IO.puts(reason)

      {:ok, u} ->
        IO.puts("Se ingresó al equipo correctamente")
        SesionGlobal.iniciar_sesion(u)
    end
  end

  def mentores(:participante) do
    mentores =
      NodoCliente.ejecutar(:obtener_mentores, ["lib/hackaton/adapter/persistencia/usuario.csv"])

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

  def log_out(_) do
    SesionGlobal.logout()
    IO.puts("Se cerró sesión correctamente")
  end

  def ver_comandos(_) do
    IO.puts("------ COMANDOS DISPONIBLES ------")

    rol =
      if SesionGlobal.usuario_actual() != nil, do: SesionGlobal.usuario_actual().rol, else: nil

    case rol do
      "ADMIN" ->
        Enum.each(Comandos.comandos_admin ++ Comandos.comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      "PARTICIPANTE" ->
        Enum.each(Comandos.comandos_participante ++ Comandos.comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      "MENTOR" ->
        Enum.each(Comandos.comandos_mentor ++ Comandos.comandos_global_base, fn comando ->
          IO.puts("/#{comando}")
        end)

      nil ->
        Enum.each(Comandos.comandos_incognito, fn comando ->
          IO.puts("/#{comando}")
        end)
    end
  end

  def project(_, nombre) do
    case NodoCliente.ejecutar(:obtener_proyecto_nombre, [
           "lib/hackaton/adapter/persistencia/proyecto.csv",
           nombre
         ]) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        case NodoCliente.ejecutar(:obtener_equipo_id, [
               "lib/hackaton/adapter/persistencia/equipo.csv",
               p.id_equipo
             ]) do
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

  def my_team(:participante) do
    equipo =
      NodoCliente.ejecutar(:obtener_equipo_id, [
        "lib/hackaton/adapter/persistencia/equipo.csv",
        SesionGlobal.usuario_actual().id_equipo
      ])

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, e} -> IO.puts("#{e.nombre} — Tema: #{e.tema}")
    end
  end

  def cambiar_estado_proyecto(:participante) do
    nuevo_estado =
      IO.gets("Ingrese el nuevo estado (proceso finalizado): ")
      |> String.trim()

    actualizado =
      NodoCliente.ejecutar(:actualizar_estado_proyecto, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        SesionGlobal.usuario_actual().id_equipo,
        nuevo_estado
      ])

    case actualizado do
      {:error, reason} -> IO.puts(reason)
      {:ok, _proyecto} -> IO.puts("Se actualizó el estado del proyecto correctamente")
    end
  end

  def actualizar_campo(_rol, tipo_campo, campo_nuevo) do
    case NodoCliente.ejecutar(:actualizar_campo_usuario, [
           "lib/hackaton/adapter/persistencia/usuario.csv",
           SesionGlobal.usuario_actual().id,
           campo_nuevo,
           String.to_atom(tipo_campo)
         ]) do
      {:ok, _usuario} ->
        IO.puts("Se actualizó el usuario correctamente")

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  def mi_info(_rol) do
    usuario = SesionGlobal.usuario_actual()

    equipo =
      case NodoCliente.ejecutar(:obtener_equipo_id, [
             "lib/hackaton/adapter/persistencia/usuario.csv",
             usuario.id_equipo
           ]) do
        {:ok, equipo} -> equipo.nombre
        {:error, _} -> "Sin equipo"
      end

    IO.puts("""
    ----------------------------------------
    Nombre:         #{usuario.nombre}
    Apellido:       #{usuario.apellido}
    Cedula:         #{usuario.cedula}
    Correo:         #{usuario.correo}
    Telefono:       #{usuario.telefono}
    Usuario:        #{usuario.usuario}
    Equipo:         #{equipo}
    ----------------------------------------
    """)
  end

end
