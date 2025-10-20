defmodule Proyecto do

  defstruct nombre: "", descripción: "", categoria: "", estado: "", equipo: %Equipo {}, historial: ""

  def crear_proyecto(nombre, descripcion, categoria, estado, equipo, historial) do
    %Proyecto{nombre: nombre, descripción: descripcion, categoria: categoria,
    estado: estado, equipo: equipo}
  end
end
