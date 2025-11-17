defmodule Hackaton.Adapter.Comandos do
  alias Hackaton.Util.SesionGlobal

  @argumentos_por_rol %{
    incognito: %{
      login: [],
      registrarse: [],
      help: [],
      salir: []
    },
    participante: %{
      salir_hackaton: [],
      join: ["nombre_equipo"],
      mentores: [],
      project: ["nombre_proyecto"],
      crear_proyecto: [],
      crear_avance: [],
      registrarse: [],
      cambiar_estado_proyecto: [],
      my_team: [],
      registrar_equipo: [],
      mostrar_historial: [],
      crear_avance: [],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: [],
      abrir_chat: ["otro usuario"],
      chat_grupo: [],
      ver_avances: []
    },
    admin: %{
      expulsar_usuario: ["usuario"],
      teams: [],
      project: ["nombre_proyecto"],
      registrar_mentor: [],
      mostrar_historial: ["nombre_proyecto"],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: [],
      crear_sala: [],
      consultar_proyecto_categoria: ["categoria"],
      conultar_proyecto_estado: ["estado"]
    },
    mentor: %{
      crear_retroalimentacion: ["nombre_proyecto"],
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

    cond do
    comando not in comandos_global() ->
        IO.puts("Comando desconocido: #{comando}")
        :error
      # 1. El comando no existe para este rol
      comando not in comandos_disponibles ->
        IO.puts("El comando #{comando} no está disponible")
        :error

      # 2. Cantidad incorrecta de argumentos
      true ->
        esperados = argumentos_para(rol_atom, comando)

        if esperados != nil and length(args) != length(esperados) do
          IO.puts("""
          Uso incorrecto del comando '#{comando}'.

          Argumentos esperados:
          #{Enum.join(esperados, ", ")}

          Tú pasaste #{length(args)} argumentos.
          """)

          :error
        else
          # 3. Verificar si la función existe
          func_info = Hackaton.Adapter.Adapters.Adapter.__info__(:functions)
          aridad = length(args) + 1

          if {comando, aridad} not in func_info do
            IO.puts("La función #{comando}/#{aridad} no existe en el Adapter.")
            :error
          else
            # 4. Ejecutar normalmente
            apply(Hackaton.Adapter.Adapters.Adapter, comando, [rol_atom | args])
          end
        end
    end
  end
end
