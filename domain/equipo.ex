defmodule Equipo do

  defstruct id: "", nombre: "", participantes: []

  def crear_equipo(id, nombre, participantes) do
    %Equipo{id: id, nombre: nombre, participantes: participantes}
  end
  
end
