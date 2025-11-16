defmodule Hackaton.Main do
  alias Hackaton.Adapter.Adapters.Adapter
  @nodo_remoto :nodoservidor@localhost
  def main do

    {:ok, _} = Hackaton.Util.SesionGlobal.start_link([])
    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Servicio conectado correctamente")
        #IO.inspect(Adapter.registrarse(:participante))
        IO.puts("Escriba un comando para iniciar.\n")
        Adapter.escuchar_comandos()
      false -> IO.puts("No se pudo conectar con el servicio remoto")

    end
  end
end
Hackaton.Main.main()
