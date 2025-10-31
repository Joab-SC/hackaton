defmodule Hackaton.Domain.Mensaje do

  defstruct id: "", tipo_mensaje: "", tipo_receptor: "", id_receptor: "", contenido: "", id_equipo: "", timestamp: "", id_proyecto: ""


  def crear_mensaje(id, tipo_mensaje, tipo_receptor, id_receptor, contenido, timestamp) do
    %Mensaje{id: id, tipo_mensaje: tipo_mensaje, tipo_receptor: tipo_receptor, id_receptor: id_receptor, contenido: contenido, timestamp: timestamp}
  end

  def crear_mensaje(id, :avance, tipo_receptor, id_receptor, contenido, timestamp, id_proyecto) do
    %Mensaje{id: id, tipo_mensaje: tipo_mensaje, tipo_receptor: tipo_receptor, id_receptor: id_receptor, contenido: contenido, timestamp: timestamp, id_proyecto: id_proyecto}
  end
end
