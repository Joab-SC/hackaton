defmodule Hackaton.Main do
  alias Hackaton.Adapter.Adapters.Adapter
  @nodo_remoto :nodoservidor@localhost
  def main do
    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Servicio conectado correctamente")
        IO.inspect(Adapter.registrarse(:participante))
      false -> IO.puts("No se pudo conectar con el servicio remoto")

    end
  end
end
Hackaton.Main.main()
