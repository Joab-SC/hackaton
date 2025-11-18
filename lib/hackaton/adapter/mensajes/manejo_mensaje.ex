defmodule Hackaton.Adapter.Mensajes.ManejoMensajes do
  alias Hackaton.Comunicacion.NodoCliente

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

    tarea = Task.async(fn -> lector(otro, actual, funcion_obtener_mensajes_pendientes_atomo) end)
    escritor(actual, otro, funcion_crear_mensajes_atomo)
    Task.shutdown(tarea, :brutal_kill)
  end

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
      Task.async(fn -> lector(otro, actual, extra, funcion_obtener_mensajes_pendientes_atomo) end)

    escritor(actual, otro, extra, funcion_crear_mensajes_atomo)
    Task.shutdown(tarea, :brutal_kill)
  end

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


end
