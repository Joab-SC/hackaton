defmodule Equipo do

  defstruct id: "", nombre: "",  tema: ""

  def crear_equipo(id, nombre, tema) do
    %Equipo{id: id, nombre: nombre,  tema: tema}
  end

end
