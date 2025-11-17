defmodule Hackaton.Adapter.Comandos do
  alias Hackaton.Util.SesionGlobal

  @argumentos_por_rol %{
    incognito: %{
      login: ["email", "password"],
      registrarse: ["email", "password", "nombre"],
      help: [],
      salir: []
    },
    participante: %{
      join: ["id_equipo"],
      entrar_sala: ["id_sala"],
      mentores: [],
      project: ["id_proyecto"],
      crear_proyecto: ["nombre", "descripcion"],
      agregar_avance: ["id_proyecto"],
      registrarse: ["email", "password", "nombre"],
      cambiar_estado_proyecto: ["id_proyecto", "nuevo_estado"],
      my_team: [],
      registrar_equipo: ["nombre_equipo"],
      mostrar_historial: ["id_proyecto"],
      crear_avance: ["id_proyecto"],
      chat: ["mensaje"],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: []
    },
    admin: %{
      enviar_comunicado: ["mensaje"],
      teams: [],
      project: ["id_proyecto"],
      crear_sala: ["nombre_sala"],
      registrar_mentor: ["email", "password", "nombre"],
      eliminar_usuario: ["id_usuario"],
      mostrar_historial: ["id_proyecto"],
      chat: ["mensaje"],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: []
    },
    mentor: %{
      entrar_sala: ["id_sala"],
      crear_retroalimentacion: ["id_proyecto"],
      chat: ["mensaje"],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: []
    }
  }

  def comandos_incognito do
    Map.keys(@argumentos_por_rol.incognito)
  end

  def comandos_admin do
    Map.keys(@argumentos_por_rol.admin)
  end

  def comandos_participante do
    Map.keys(@argumentos_por_rol.participante)
  end

  def comandos_mentor do
    Map.keys(@argumentos_por_rol.mentor)
  end

  def comandos_global do
    Enum.uniq(
      comandos_incognito() ++ comandos_admin() ++ comandos_participante() ++ comandos_mentor()
    )
  end

  # -----------------------------
  # Helpers para leer el mapa
  # -----------------------------

  def comandos_de_rol(rol_atom) do
    Map.keys(@argumentos_por_rol[rol_atom] || %{})
  end

  def argumentos_para(rol_atom, comando) do
    @argumentos_por_rol
    |> Map.get(rol_atom, %{})
    |> Map.get(comando, nil)
  end

  # -----------------------------
  # Lógica de escucha
  # -----------------------------

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
    comando = partes |> hd() |> String.to_atom()
    args = partes |> tl()
    ejecutar_comando(comando, args)
  end

  defp procesar_entrada(_),
    do: IO.puts("Por favor escriba un comando válido que empiece con /")

  # -----------------------------
  # Ejecución de comandos
  # -----------------------------

  def ejecutar_comando(comando, args) do
    usuario = SesionGlobal.usuario_actual()

    rol_atom =
      case usuario && usuario.rol do
        "PARTICIPANTE" -> :participante
        "ADMIN" -> :admin
        "MENTOR" -> :mentor
        _ -> :incognito
      end

    comandos_disponibles = comandos_de_rol(rol_atom)

    # comando no existe en este rol
    if comando not in comandos_disponibles do
      IO.puts("El comando #{comando} no está disponible para este rol")
      return(:error)
    end

    # argumentos esperados
    esperados = argumentos_para(rol_atom, comando)

    # cantidad incorrecta
    if esperados != nil and length(args) != length(esperados) do
      IO.puts("""
      Uso incorrecto del comando '#{comando}'.

      Argumentos esperados:
      #{Enum.join(esperados, ", ")}

      Tú pasaste #{length(args)} argumentos.
      """)

      return(:error)
    end

    # verificar función definida
    func_info = Hackaton.Adapter.Adapters.Adapter.__info__(:functions)
    aridad = length(args) + 1

    if {comando, aridad} not in func_info do
      IO.puts("La función #{comando}/#{aridad} no existe en el Adapter.")
      return(:error)
    end

    # ejecutar
    apply(Hackaton.Adapter.Adapters.Adapter, comando, [rol_atom | args])
  end
end
