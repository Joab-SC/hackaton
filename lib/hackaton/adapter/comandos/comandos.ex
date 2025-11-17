defmodule Hackaton.Adapter.Comandos do
  alias Hackaton.Util.SesionGlobal
  @comandos_incognito [:login, :help, :registrarse, :salir]
  @comandos_global_base [:chat, :log_out, :actualizar_campo, :mi_info, :help, :salir]
  @comandos_admin [
                    :enviar_comunicado,
                    :teams,
                    :project,
                    :crear_sala,
                    :registrar_mentor,
                    :eliminar_usuario,
                    :mostrar_historial
                  ] ++ @comandos_global_base
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
                           :registrar_equipo,
                           :mostrar_historial
                         ] ++ @comandos_global_base
  @comandos_mentor [:entrar_sala] ++ @comandos_global_base
  @comandos_global Enum.uniq(
                     @comandos_incognito ++
                       @comandos_global_base ++
                       @comandos_admin ++
                       @comandos_participante ++
                       @comandos_mentor
                   )



  def comandos_incognito do
    @comandos_incognito
  end

  def comandos_admin do
    @comandos_admin
  end

  def comandos_participante do
    @comandos_participante
  end

  def comandos_mentor do
    @comandos_mentor
  end

  def comandos_global do
    @comandos_global
  end

  def comandos_global_base do
    @comandos_global_base
  end

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
          nil -> {@comandos_incognito, :incognito}
          _ -> {[], :nada}
        end

      if comando in comandos_disponibles do
        try do
          func_info = Hackaton.Adapter.Adapters.Adapter.__info__(:functions)

          if {comando, length(args) + 1} in func_info do
            apply(Hackaton.Adapter.Adapters.Adapter, comando, [atomo_aridad | args])
          else
            IO.puts(
              "El comando '#{comando}' espera #{length(args) + 1} argumentos, tú pasaste #{length(args)}"
            )
          end
        rescue
          e in FunctionClauseError ->
            {_, _, aridad} = e.function

            IO.puts(
              "El comando '#{comando}' no se pudo ejecutar, se esperaban #{aridad} datos y tu ingresaste #{length(args)} cantidad de argumentos"
            )

          e in UndefinedFunctionError ->
            {_, _, aridad} = e.function

            IO.puts(
              "El comando '#{comando}' no se pudo ejecutar, se esperaban #{aridad} datos y tu ingresaste #{length(args)} cantidad de argumentos"
            )

          _ ->
            IO.puts("Ocurrió un error inesperado al ejecutar el comando '#{comando}'.")
        end
      else
        IO.puts("El comando #{comando} no está disponible para este rol")
      end
    end
  end
end
