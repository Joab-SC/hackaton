defmodule Hackaton.Util.SesionGlobal do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{usuario: nil} end, name: __MODULE__)
  end
end

defmodule Sesion do
  def iniciar_sesion(usuario_struct) do
    Agent.update(SesionGlobal, &Map.put(&1, :usuario, usuario_struct))
  end

  def usuario_actual() do
    Agent.get(SesionGlobal, & &1.usuario)
  end

  def logout() do
    Agent.update(SesionGlobal, &Map.put(&1, :usuario, nil))
  end
end
