defmodule Hackaton.Comunicacion.NodoCliente do
  @nodo_remoto :nodoservidor@localhost
  @servicio_remoto {:servicio_hackaton, @nodo_remoto}


  def main() do
    IO.puts("=== Nodo Cliente Iniciado ===")
    Hackaton.Adapter.Adapters.Adapter.escuchar_comandos()
  end
  
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
