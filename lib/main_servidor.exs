defmodule Hackaton.MainServidor do

  def main do
    IO.puts("Iniciando servidor Hackaton...")

    {:ok, pid} = Hackaton.AppServidor.start_link(nil)

    IO.puts("Servidor iniciado correctamente. PId #{inspect(pid)}")
    Process.sleep(:infinity)
  end
end

Hackaton.MainServidor.main()
