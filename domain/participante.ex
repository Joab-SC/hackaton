defmodule Participante do

  defstruct id: "", nombre: "", apellido: "", cedula: "",
  correo: "", teléfono: "", usuario: "", contrasena: "", id_equipo: ""

  def crear_participante(id, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo) do
    %Participante{id: id, nombre: nombre, apellido: apellido, cedula: cedula,
    correo: correo, teléfono: telefono, usuario: usuario, contrasena: contrasena, id_equipo: id_equipo}
  end

end
