defmodule Hackaton.Adapter.Adapters.Adapter do

  alias Hackaton.Services.ServicioHackathon
  alias Hackaton.Util.SesionGlobal


  @comandos_admin [:enviar_comunicado, :teams, :project, :crear_sala, :registrarse, :eliminar_usuario]
  @comandos_usuario [:join, :entrar_sala, :mentores, :project, :crear_proyecto, :agregar_avance, :registrarse]
  @comandos_mentor [:entrar_sala]
  @comandos_global_base [:chat, :login, :log_out, :ver_comandos ]
  @comandos_global (
  @comandos_global_base ++
  @comandos_admin ++
  @comandos_usuario ++
  @comandos_mentor
  |> Enum.uniq()
)


  def registrarse(:participante) do
    IO.puts("------ REGISTRANDO PARTICIPANTE------ ")
    nombre = IO.gets("Ingrese su nombre: ")
    |> String.trim()
    apellido = IO.gets("Ingrese su apellido: ")
    |> String.trim()
    cedula = IO.gets("Ingrese su cedula: ")
    |> String.trim()
    correo = IO.gets ("Ingrese su correo: ")
    |> String.trim()
    telefono = IO.gets("Ingrese su telefono: ")
    |> String.trim()
    usuario = IO.gets("Ingrese su usuario: ")
    |> String.trim()
    contrasena = IO.gets("Ingrese su contraseña: ")
    |> String.trim()

    usuario = ServicioHackathon.registrar_usuario("usuario.csv", "PARTICIPANTE", nombre, apellido, cedula, correo, telefono, usuario, contrasena)
    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def registrarse(:mentor) do
    IO.puts("------ REGISTRANDO MENTOR------ ")
    nombre = IO.gets("Ingrese su nombre: ")
    |> String.trim()
    apellido = IO.gets("Ingrese su apellido: ")
    |> String.trim()
    cedula = IO.gets("Ingrese su cedula: ")
    |> String.trim()
    correo = IO.gets ("Ingrese su correo: ")
    |> String.trim()
    telefono = IO.gets("Ingrese su telefono: ")
    |> String.trim()
    usuario = IO.gets("Ingrese su usuario: ")
    |> String.trim()
    contrasena = IO.gets("Ingrese su contraseña: ")
    |> String.trim()

    usuario = ServicioHackathon.registrar_usuario("usuario.csv", "MENTOR", nombre, apellido, cedula, correo, telefono, usuario, contrasena)
    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  def login() do
    IO.puts("------ INICIANDO SESIÓN ------ ")
    usuario = IO.gets("Ingrese su usuario: ")
    contrasena = IO.gets("Ingrese su contrasena: ")

    usuario = ServicioHackathon.iniciar_sesion("usuario.csv", usuario, contrasena)
    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se inició sesion correctamente")
    end
  end

  def crear_proyecto() do
    IO.puts("------ CREANDO PROYECTO ------ ")
    nombre = IO.gets("Ingrese el nombre de su proyecto")
    descripcion = IO.gets("Ingrese la descripcion")
    categoria = IO.gets("Elija categoria: ")
    nombre_equipo = IO.gets("Ingrese el nombre de su equipo")
    proyecto = ServicioHackathon.crear_proyecto("proyecto.csv", nombre, descripcion, categoria, nombre_equipo)
    case proyecto do
      {:error, reason} ->  IO.puts(reason)
      {:ok, _proyecto} -> IO.puts("Se creo el proyecto exitosamente")
    end
  end

  def salir_hackaton() do
    usuario = ServicioHackathon.eliminar_usuario("usuario.csv", SesionGlobal.usuario_actual().id, :id)
    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok ->  IO.puts("Se salio correctamente de la hackaton")
    end
  end

  def expulsar_usuario(user) do
    usuario = ServicioHackathon.eliminar_usuario("usuario.csv", user, :user)
    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok ->  IO.puts("Se expulsó correctamente de la hackaton")
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
    ingreso = ServicioHackathon.unirse_por_nombre("usuario.csv", "equipo.csv", SesionGlobal.usuario_actual().id , nombre_equipo)
    case ingreso do
      {:error, reason} -> IO.puts(reason)
      {:ok, _} -> IO.puts("Se ingreso ak equipo correctamente")
    end
  end

  def mentores() do
    mentores = ServicioHackathon.obtener_mentores("usuario.csv")
    Enum.each(usuarios, fn u ->
      IO.puts("""
      ----------------------------------------
      Rol:           #{u.rol}
      Nombre:        #{u.nombre} #{u.apellido}
      Cédula:        #{u.cedula}
      Correo:        #{u.correo}
      Teléfono:      #{u.telefono}
      Usuario:       #{u.usuario}
      ----------------------------------------
      """)
    end)
  end

  def log_out do
   ServicioHackathon.cerrar_sesion()
  end

  def ver_comandos() do
    case SesionGlobal.usuario_actual().rol do
      
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
