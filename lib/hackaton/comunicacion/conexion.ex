defmodule Hackaton.Comunicacion.Conexion do
  @moduledoc """
  Configuración de la comunicación distribuida entre el nodo cliente y el nodo servidor.

  Todo lo que antes estaba *hardcodeado* (`:nodoservidor@joab`, `--cookie hackaton`) vive
  aquí, y se resuelve **en tiempo de ejecución**, para que cualquiera pueda clonar el
  repositorio y probar el sistema sin editar código:

    * **Cookie**: se fija sola (`:hackaton` por defecto), así que no hace falta pasar
      `--cookie` en la línea de comandos. Se puede cambiar con la variable de entorno
      `HACKATON_COOKIE` (útil si ese nombre ya está tomado en tu red de Erlang).

    * **Nodo servidor**: por defecto se asume que el servidor corre en la **misma máquina**
      que el cliente, así que el cliente busca `nodoservidor@<host de esta máquina>`.
      Para un servidor en **otra máquina**, usa la variable de entorno
      `HACKATON_SERVIDOR` con el nombre que el servidor imprime al arrancar
      (por ejemplo `HACKATON_SERVIDOR=nodoservidor@192.168.1.50`).

  ## Ejemplos

      # Servidor y cliente en la misma máquina (no hay que configurar nada)
      elixir --sname nodoservidor -S mix run --no-halt lib/main_servidor.exs
      elixir --sname nodocliente -S mix run lib/main.exs

      # Cliente apuntando a un servidor en otra máquina
      HACKATON_SERVIDOR=nodoservidor@maquina-del-servidor \\
        elixir --sname nodocliente -S mix run lib/main.exs

  Ambos nodos deben estar **distribuidos** (arrancados con `--sname` o `--name`);
  si no, no hay forma de que se comuniquen entre sí.
  """

  @nombre_servicio :servicio_hackaton
  @nombre_nodo_servidor "nodoservidor"
  @cookie_por_defecto :hackaton
  @var_nodo "HACKATON_SERVIDOR"
  @var_cookie "HACKATON_COOKIE"

  # ---------------------------------------------------------------------------
  #  Configuración
  # ---------------------------------------------------------------------------

  @doc """
  Nombre con el que el servidor registra su proceso (el "buzón" que atiende peticiones).
  """
  def nombre_servicio, do: @nombre_servicio

  @doc """
  Variable de entorno que permite apuntar el cliente a un servidor de otra máquina.
  """
  def variable_nodo, do: @var_nodo

  @doc """
  Cookie de Erlang que comparten ambos nodos: `HACKATON_COOKIE` o `:hackaton` por defecto.
  """
  def cookie do
    case System.get_env(@var_cookie) do
      nil -> @cookie_por_defecto
      "" -> @cookie_por_defecto
      valor -> String.to_atom(valor)
    end
  end

  @doc """
  Fija la cookie del nodo actual en tiempo de ejecución.

  Devuelve `:ok`, o `{:error, :nodo_no_distribuido}` si el nodo se arrancó sin `--sname`
  / `--name` (en ese caso no puede haber comunicación con otro nodo).
  """
  def configurar_cookie do
    if Node.alive?() do
      Node.set_cookie(cookie())
      :ok
    else
      {:error, :nodo_no_distribuido}
    end
  end

  # ---------------------------------------------------------------------------
  #  Resolución del nodo servidor
  # ---------------------------------------------------------------------------

  @doc """
  Resuelve el nodo servidor al que el cliente debe conectarse.

  Devuelve `{:ok, nodo}` o `{:error, :nodo_no_distribuido}`.

  Orden de búsqueda:

    1. La variable de entorno `#{@var_nodo}` (admite `nodoservidor@host` o solo
       `nodoservidor`, en cuyo caso se le agrega el host de esta máquina).
    2. Por defecto, `nodoservidor@<host de este nodo>` (servidor y cliente en la misma máquina).
  """
  def nodo_servidor do
    case nodo_configurado() do
      nil ->
        case Node.self() do
          :nonode@nohost -> {:error, :nodo_no_distribuido}
          nodo -> {:ok, con_host(@nombre_nodo_servidor, host_de(nodo))}
        end

      nodo ->
        {:ok, nodo}
    end
  end

  @doc """
  Dirección del servicio remoto lista para `send/2`: `{:servicio_hackaton, nodo}`.
  """
  def servicio_remoto(nodo_servidor), do: {@nombre_servicio, nodo_servidor}

  defp nodo_configurado do
    case System.get_env(@var_nodo) do
      nil ->
        nil

      "" ->
        nil

      nombre ->
        if String.contains?(nombre, "@") do
          String.to_atom(nombre)
        else
          con_host(nombre, host_local())
        end
    end
  end

  defp host_local do
    case Node.self() do
      :nonode@nohost -> "localhost"
      nodo -> host_de(nodo)
    end
  end

  defp con_host(nombre, host), do: String.to_atom("#{nombre}@#{host}")

  defp host_de(nodo) do
    nodo
    |> Atom.to_string()
    |> String.split("@", parts: 2)
    |> List.last()
  end

  # ---------------------------------------------------------------------------
  #  Mensajes para el usuario
  # ---------------------------------------------------------------------------

  @doc """
  Comando con el que se arranca el servidor (lo usamos en los mensajes de ayuda).
  """
  def comando_servidor do
    "elixir --sname nodoservidor -S mix run --no-halt lib/main_servidor.exs"
  end

  @doc """
  Comando con el que se arranca el cliente (lo usamos en los mensajes de ayuda).
  """
  def comando_cliente do
    "elixir --sname nodocliente -S mix run lib/main.exs"
  end

  @doc """
  Mensaje para cuando el nodo no está distribuido (faltó `--sname`/`--name`).
  """
  def mensaje_no_distribuido(:cliente) do
    """
    Este cliente no está distribuido, así que no puede hablar con el servidor.

    Arráncalo indicando un nombre de nodo:

        #{comando_cliente()}

    (El nombre `nodocliente` es solo un ejemplo; puedes usar el que quieras.)
    """
  end

  def mensaje_no_distribuido(:servidor) do
    """
    Este servidor no está distribuido: ningún cliente podrá conectarse a él.

    Arráncalo indicando un nombre de nodo:

        #{comando_servidor()}
    """
  end

  @doc """
  Mensaje de bienvenida tras conectar con el servidor.
  """
  def mensaje_conectado(nodo_servidor) do
    """
    Servicio conectado correctamente (#{nodo_servidor}).
    Escriba un comando para iniciar. Si no sabe por dónde empezar, pruebe con /help
    """
  end

  @doc """
  Mensaje para cuando el servidor no responde, con las causas más comunes.
  """
  def mensaje_conexion_fallida(nodo_servidor) do
    """
    No se pudo conectar con el servicio remoto #{nodo_servidor}.

    Revise que:
      1. El servidor esté corriendo en otra terminal:
         #{comando_servidor()}
      2. Los dos nodos usen la misma cookie (el programa ya la fija solo).
      3. Si el servidor está en OTRA máquina, indique su nombre aquí:
         #{@var_nodo}=nodoservidor@IP_O_HOST elixir --sname nodocliente -S mix run lib/main.exs
      4. Ambas máquinas se "vean" entre sí (hostnames resolubles y puerto 4369 de epmd abierto).
    """
  end
end
