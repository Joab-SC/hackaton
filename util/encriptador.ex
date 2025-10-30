defmodule Encriptador do

  # Convierte la contraseña en un hash irreversible
  def hash_contrasena(contrasena) do
    :crypto.hash(:sha256, contrasena)
    |> Base.encode16(case: :lower)
  end

  # Compara una contraseña ingresada con el hash guardado
  def verificar_contrasena(contrasena, hash_guardado) do
    hash_contrasena(contrasena) == hash_guardado
  end
end
