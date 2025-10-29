defmodule Proyecto do

  defstruct id: "", nombre: "", descripción: "", categoria: "", estado: "", id_equipo: "", fecha_creacion: ""

  def crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    %Proyecto{id: id, nombre: nombre, descripción: descripcion, categoria: categoria,
    estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
  end
end
