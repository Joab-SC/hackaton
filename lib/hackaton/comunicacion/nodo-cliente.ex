defmodule Hackaton.Comunicacion.NodoCliente do
  @moduledoc """
  Cliente distribuido: resuelve el nodo servidor (ver `Hackaton.Comunicacion.Conexion`),
  le envía cada petición y espera su respuesta.
  """

  alias Hackaton.Comunicacion.Conexion

  @doc """
  Ejecuta una operación en el servidor y devuelve su respuesta.
  """
  def ejecutar(funcion, args) do
    case Conexion.nodo_servidor() do
      {:ok, nodo_servidor} ->
        enviar_solicitud(nodo_servidor, funcion, args)
        recibir_respuesta()

      {:error, _motivo} ->
        {:error, "Sin conexión con el servidor. Verifique que esté corriendo."}
    end
  end

  @doc """
  Envía la petición al servicio remoto del nodo servidor.
  """
  def enviar_solicitud(nodo_servidor, funcion, args) do
    send(Conexion.servicio_remoto(nodo_servidor), {self(), funcion, args})
  end

  @doc """
  Espera la respuesta del servidor.
  """
  def recibir_respuesta do
    receive do
      retorno -> retorno
    end
  end
end
