defmodule Participante do

  defstruct nombre: "", apellido: "", cedula: "",
  correo: "", teléfono: "", usuario: "", contrasena: ""

  def crear_mentor(nombre, apellido, cedula, correo, telefono, usuario, contrasena) do
    %Participante{nombre: nombre, apellido: apellido, cedula: cedula,
    correo: correo, teléfono: telefono, usuario: usuario}
  end

end
