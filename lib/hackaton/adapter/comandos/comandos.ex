defmodule Hackaton.Adapter.Comandos do
  @moduledoc """
  Módulo encargado de gestionar y validar los comandos ingresados por el usuario
  en la consola del sistema.

  Este módulo cumple varias funciones clave:

    * Mantiene la lista de comandos disponibles por cada rol
      (`incognito`, `participante`, `admin`, `mentor`).

    * Permite saber qué argumentos requiere cada comando.

    * Implementa un ciclo de escucha interactivo que interpreta comandos
      iniciados con `/`.

    * Valida:
        - Que el comando exista.
        - Que el rol del usuario tenga permiso para ejecutarlo.
        - Que el número de argumentos coincida con lo esperado.
        - Que la función implementada exista en el módulo `Adapter`.

    * Finalmente, ejecuta el comando correspondiente haciendo `apply/3`
      en el módulo `Hackaton.Adapter.Adapters.Adapter`.

  Es un componente esencial del sistema, ya que actúa como “router” o
  intermediario entre la entrada del usuario y la lógica de negocio.
  """

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
      chat_grupo_mentor: ["user mentor"],
      ver_avances: [],
      entrar_sala: [],
      ver_anuncios: []
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
      consultar_proyecto_estado: ["estado"],
      enviar_anuncio: [],
      ver_anuncios: []
    },
    mentor: %{
      crear_retroalimentacion: ["nombre_proyecto"],
      log_out: [],
      actualizar_campo: ["campo", "valor"],
      mi_info: [],
      help: [],
      salir: [],
      chat_grupo: ["nombre_equipo"],
      ver_anuncios: []
    }
  }


  @doc """
  Retorna la lista de comandos disponibles para un usuario **incognito**.
  """
  def comandos_incognito do
    Map.keys(@argumentos_por_rol.incognito)
  end

  @doc """
  Retorna la lista de comandos disponibles para los usuarios con rol **admin**.
  """
  def comandos_admin do
    Map.keys(@argumentos_por_rol.admin)
  end

  @doc """
  Lista los comandos permitidos para los **participantes**.
  """
  def comandos_participante do
    Map.keys(@argumentos_por_rol.participante)
  end

  @doc """
  Lista los comandos disponibles para el rol **mentor**.
  """
  def comandos_mentor do
    Map.keys(@argumentos_por_rol.mentor)
  end

  @doc """
  Retorna un conjunto único de todos los comandos del sistema,
  independientemente del rol.
  """
  def comandos_global do
    Enum.uniq(
      comandos_incognito() ++ comandos_admin() ++ comandos_participante() ++ comandos_mentor()
    )
  end


  @doc """
  Retorna los comandos disponibles para un rol determinado (`rol_atom`).

  Si el rol no existe, retorna un mapa vacío.
  """
  def comandos_de_rol(rol_atom) do
    Map.keys(@argumentos_por_rol[rol_atom] || %{})
  end

  @doc """
  Obtiene la lista de argumentos que espera un comando según el rol.
  """
  def argumentos_para(rol_atom, comando) do
    @argumentos_por_rol
    |> Map.get(rol_atom, %{})
    |> Map.get(comando, nil)
  end


  @doc """
  Inicia un ciclo de escucha continua para leer comandos ingresados
  por el usuario en la terminal.

  Solo se procesan entradas que comienzan con `/`.
  """
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


  @doc """
  Punto central de ejecución de cualquier comando del sistema.

  Esta función se encarga de:

    1. Verificar el rol del usuario actual mediante `SesionGlobal`.
    2. Revisar si el comando existe en el sistema.
    3. Validar si el comando está permitido para el rol actual.
    4. Revisar si la cantidad de argumentos coincide con lo esperado.
    5. Verificar que la función exista en el módulo `Adapter`.
    6. Ejecutar dinámicamente la función usando `apply/3`.

  Si algún paso falla, imprime el error correspondiente y NO ejecuta el comando.
  """
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

      comando not in comandos_disponibles ->
        IO.puts("El comando #{comando} no está disponible para tu rol.")
        :error

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
          func_info = Hackaton.Adapter.Adapters.Adapter.__info__(:functions)
          aridad = length(args) + 1

          if {comando, aridad} not in func_info do
            IO.puts("La función #{comando}/#{aridad} no existe en el Adapter.")
            :error
          else
            apply(Hackaton.Adapter.Adapters.Adapter, comando, [rol_atom | args])
          end
        end
    end
  end
end
