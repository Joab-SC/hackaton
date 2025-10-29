defmodule Usuario do

  defstruct id: "", rol: "", nombre: "", apellido: "", cedula: "",
  correo: "", teléfono: "", usuario: "", contrasena: "", id_equipo: ""

  def crear_usuario(id, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo) do
    %Usuario{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
    correo: correo, teléfono: telefono, usuario: usuario, contrasena: contrasena, id_equipo: id_equipo}
  end

end
