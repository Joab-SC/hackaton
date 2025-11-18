defmodule Hackaton.Adapter.Mensajes.ManejoMensajes do
  @moduledoc """
  Módulo encargado de manejar la lógica de envío, recepción y visualización
  de mensajes dentro del sistema de chat del Hackaton.

  Este módulo funciona como un "cliente local" que interactúa con el nodo remoto
  (`NodoCliente`) para:

    * Obtener mensajes (historial o pendientes).
    * Marcar mensajes como leídos.
    * Enviar nuevos mensajes.
    * Mostrar mensajes formateados por consola.
    * Ejecutar chats simultáneos usando `Task.async/1`.

  Incluye dos versiones de cada flujo de chat:

    * Chat **uno a uno** (emisor ↔ receptor).
    * Chat **con contexto extra** (ej. salas, grupos).

  Todos los mensajes son consultados y persistidos mediante llamadas a
  `NodoCliente.ejecutar/2`, que se comunica con el nodo servidor distribuido.
  """

  alias Hackaton.Comunicacion.NodoCliente


  @doc """
  Ciclo recursivo que se encarga de:

    * Obtener mensajes pendientes entre `emisor` y `receptor`.
    * Mostrarlos por consola.
    * Marcar como leídos dichos mensajes.
    * Continuar escuchando indefinidamente.

  Este flujo se detiene únicamente cuando el proceso padre termina o es
  detenido mediante `Task.shutdown`.
  """
  def lector(emisor, receptor, funcion_obtener_mensajes_atomo) do
    case NodoCliente.ejecutar(funcion_obtener_mensajes_atomo, [
           "lib/hackaton/adapter/persistencia/mensaje.csv",
           emisor.id,
           receptor.id
         ]) do
      {:error, _} ->
        lector(emisor, receptor, funcion_obtener_mensajes_atomo)

      {:ok, mensajes} ->
        mostrar_mensajes_chat(mensajes)
        IO.write("Escribir: ")

        NodoCliente.ejecutar(:marcar_leidos, [
          "lib/hackaton/adapter/persistencia/mensaje.csv",
          mensajes
        ])

        lector(emisor, receptor, funcion_obtener_mensajes_atomo)
    end
  end


  @doc """
  Ciclo recursivo para enviar mensajes desde `emisor` hacia `receptor`.

  Flujo:

    * Solicita texto al usuario.
    * Si escribe `/salir`, finaliza el chat.
    * Envía el mensaje mediante el nodo del servidor.
    * En caso de error, reintenta.
    * En caso de éxito, continúa escribiendo.

  No bloquea la lectura, la cual se ejecuta simultáneamente con un `Task`.
  """
  def escritor(emisor, receptor, funcion_crear_mensajes_atomo) do
    contenido = String.trim(IO.gets("Escribir: "))

    if contenido == "/salir" do
      :ok
    else
      case NodoCliente.ejecutar(funcion_crear_mensajes_atomo, [
             "lib/hackaton/adapter/persistencia/mensaje.csv",
             emisor.id,
             receptor.id,
             contenido
           ]) do
        {:error, reason} ->
          IO.puts(reason)
          escritor(emisor, receptor, funcion_crear_mensajes_atomo)

        {:ok, _} ->
          escritor(emisor, receptor, funcion_crear_mensajes_atomo)
      end
    end
  end


  @doc """
  Inicia un chat uno a uno entre `actual` y `otro`.

  Acciones que realiza:

    * Obtiene los mensajes previos.
    * Los marca como leídos.
    * Los imprime formateados.
    * Inicia un proceso asíncrono (`Task.async`) que escucha mensajes entrantes.
    * Inicia el proceso de escribir mensajes.
    * Finaliza el lector al terminar.

  `funcion_crear_mensajes_atomo`
  `funcion_obtener_mensajes_atomo`
  `funcion_obtener_mensajes_pendientes_atomo`
  son funciones remotas ejecutadas en el servidor.
  """
  def chatear(
        actual,
        otro,
        funcion_crear_mensajes_atomo,
        funcion_obtener_mensajes_atomo,
        funcion_obtener_mensajes_pendientes_atomo
      ) do

    IO.inspect(otro, label: "Otro Usuario")
    IO.inspect(actual, label: "Usuario Actual")

    case NodoCliente.ejecutar(funcion_obtener_mensajes_atomo, [
           "lib/hackaton/adapter/persistencia/mensaje.csv",
           otro.id,
           actual.id
         ]) do
      {:ok, mensajes} ->
        NodoCliente.ejecutar(:marcar_leidos, [
          "lib/hackaton/adapter/persistencia/mensaje.csv",
          mensajes
        ])

        mostrar_mensajes_chat(mensajes)

      {:error, reason} ->
        IO.puts(reason)
    end

    tarea = Task.async(fn ->
      lector(otro, actual, funcion_obtener_mensajes_pendientes_atomo)
    end)

    escritor(actual, otro, funcion_crear_mensajes_atomo)
    Task.shutdown(tarea, :brutal_kill)
  end


  @doc """
  Imprime un conjunto de mensajes en un formato visual tipo “burbuja”:

      ┌───────────────────────────────┐
      │   De: Usuario
      │   Hora: 2025-11-12 10:00
      │
      │   contenido del mensaje
      └───────────────────────────────┘

  Cada mensaje consulta al servidor para obtener el usuario emisor correspondiente.
  """
  def mostrar_mensajes_chat(mensajes) do
    Enum.each(mensajes, fn mensaje ->
      {_, emisor} =
        NodoCliente.ejecutar(:obtener_usuario, [
          "lib/hackaton/adapter/persistencia/usuario.csv",
          mensaje.id_emisor
        ])

      IO.puts("""

      ┌──────────────────────────────────────────────────────────────┐
      │   De: #{emisor.nombre}
      │   Hora: #{mensaje.fecha}
      │
      │   #{mensaje.contenido}
      └──────────────────────────────────────────────────────────────┘


      """)
    end)
  end


  @doc """
  Variante del lector para chats que requieren un parámetro adicional `extra`,
  por ejemplo:

    * ID de un equipo.
    * ID de una sala.
    * Chat grupal.

  El funcionamiento es idéntico al lector principal, pero enviando un argumento
  adicional al servidor.
  """
  def lector(emisor, receptor, extra, funcion_obtener_mensajes_atomo) do
    case NodoCliente.ejecutar(funcion_obtener_mensajes_atomo, [
           "lib/hackaton/adapter/persistencia/mensaje.csv",
           emisor.id,
           receptor.id,
           extra.id
         ]) do
      {:error, _} ->
        lector(emisor, receptor, extra, funcion_obtener_mensajes_atomo)

      {:ok, mensajes} ->
        mostrar_mensajes_chat(mensajes)
        IO.write("Escribir: ")

        NodoCliente.ejecutar(:marcar_leidos, [
          "lib/hackaton/adapter/persistencia/mensaje.csv",
          mensajes
        ])

        lector(emisor, receptor, extra, funcion_obtener_mensajes_atomo)
    end
  end

  @doc """
  Variante del escritor para chats con un parámetro `extra`.

  Igual que el escritor básico, pero enviando también `extra.id` al servidor.
  """
  def escritor(emisor, receptor, extra, funcion_crear_mensajes_atomo) do
    contenido = String.trim(IO.gets("Escribir: "))

    if contenido == "/salir" do
      :ok
    else
      case NodoCliente.ejecutar(funcion_crear_mensajes_atomo, [
             "lib/hackaton/adapter/persistencia/mensaje.csv",
             emisor.id,
             receptor.id,
             extra.id,
             contenido
           ]) do
        {:error, reason} ->
          IO.puts(reason)
          escritor(emisor, receptor, extra, funcion_crear_mensajes_atomo)

        {:ok, _} ->
          escritor(emisor, receptor, extra, funcion_crear_mensajes_atomo)
      end
    end
  end

  @doc """
  Controlador general para chats con parámetro adicional `extra`.

  Realiza los mismos pasos del chat uno a uno, pero ajustado para:

    * Chats grupales.
    * Salas de discusión.
    * Conversaciones de equipo.

  Utiliza `Task.async` para escuchar mensajes mientras el usuario escribe.
  """
  def chatear(
        actual,
        otro,
        extra,
        funcion_crear_mensajes_atomo,
        funcion_obtener_mensajes_atomo,
        funcion_obtener_mensajes_pendientes_atomo
      ) do
    case NodoCliente.ejecutar(funcion_obtener_mensajes_atomo, [
           "lib/hackaton/adapter/persistencia/mensaje.csv",
           otro.id,
           actual.id,
           extra.id
         ]) do
      {:ok, mensajes} ->
        NodoCliente.ejecutar(:marcar_leidos, [
          "lib/hackaton/adapter/persistencia/mensaje.csv",
          mensajes
        ])

        mostrar_mensajes_chat(mensajes)

      {:error, reason} ->
        IO.puts(reason)
    end

    tarea =
      Task.async(fn ->
        lector(otro, actual, extra, funcion_obtener_mensajes_pendientes_atomo)
      end)

    escritor(actual, otro, extra, funcion_crear_mensajes_atomo)
    Task.shutdown(tarea, :brutal_kill)
  end
end
