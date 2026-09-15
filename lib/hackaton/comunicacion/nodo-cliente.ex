defmodule Hackaton.Comunicacion.NodoCliente do
  @moduledoc """
  Cliente distribuido: envía cada petición al servicio remoto `:servicio_hackaton`
  del nodo servidor y espera su respuesta.
  """

  @nodo_remoto :nodoservidor@joab
  @servicio_remoto {:servicio_hackaton, @nodo_remoto}

  def ejecutar(funcion, args) do
    enviar_solicitud(funcion, args)
    recibir_respuesta()
  end

  def enviar_solicitud(funcion, args) do
    send(@servicio_remoto, {self(), funcion, args})
  end

  def recibir_respuesta() do
    receive do
      retorno ->
        retorno
    end

  end
end
