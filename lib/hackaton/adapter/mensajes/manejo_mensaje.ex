defmodule Hackaton.Adapter.Mensajes.ManejoMensajes do
  alias Hackaton.Comunicacion.NodoCliente

  def lector(emisor, receptor) do
    case NodoCliente.ejecutar(:obtener_mensajes_personal_pendientes, [
           "lib/hackaton/adapter/persistencia/mensaje.csv",
           emisor.id,
           receptor.id
         ]) do
      {:error, _} ->
        lector(emisor, receptor)

      {:ok, mensajes} ->
        mostrar_mensajes_chat(mensajes)

        NodoCliente.ejecutar(:marcar_leidos, [
          "lib/hackaton/adapter/persistencia/mensaje.csv",
          mensajes
        ])

        lector(emisor, receptor)
    end
  end

  def escritor(emisor, receptor) do
    contenido = String.trim(IO.gets("Escribir: "))

    if contenido == "/salir" do
      :ok
    else
      case NodoCliente.ejecutar(:crear_mensaje_personal, [
             "lib/hackaton/adapter/persistencia/mensaje.csv",
             emisor.id,
             receptor.id,
             contenido
           ]) do
        {:error, reason} ->
          IO.puts(reason)
          escritor(emisor, receptor)

        {:ok, _} ->
          escritor(emisor, receptor)
      end
    end
  end

  def chatear(actual, otro) do
    tarea = Task.async(fn -> lector(otro, actual) end)
    escritor(actual, otro)
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
