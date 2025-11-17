defmodule Hackaton.AppServidor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    children = [
      {Hackaton.Util.SesionGlobal, []},
      {Task, fn -> Hackaton.Comunicacion.NodoServidor.main() end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
