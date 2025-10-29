defmodule Equipo do

  defstruct id: "", nombre: "",  tema: ""

  def crear_equipo(id, nombre, tema, participantes) do
    %Equipo{id: id, nombre: nombre,  tema: tema}
  end

end
