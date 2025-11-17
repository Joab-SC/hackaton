defmodule Hackaton.Main do
  alias Hackaton.Adapter.Comandos
  @nodo_remoto :nodoservidor@localhost

  def main do
    # Iniciar supervisor del cliente (incluye SesionGlobal)
    {:ok, _} = Hackaton.AppCliente.start_link(nil)

    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Servicio conectado correctamente")
        IO.puts("Escriba un comando para iniciar.\n")
        Comandos.escuchar_comandos()
      false -> IO.puts("No se pudo conectar con el servicio remoto")

      false ->
        IO.puts("No se pudo conectar con el servicio remoto")
    end
  end
end

Hackaton.Main.main()
