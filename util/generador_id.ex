defmodule GeneradorID do
  def generar_id_unico(prefijo, fun_existente?) do
    id = generar_id(prefijo)

    if fun_existente?.(id) do
      generar_id_unico(prefijo, fun_existente?)
    else
      id
    end
  end

  def generar_id(prefijo) do
    aleatorio =
      :crypto.strong_rand_bytes(3)
      |> Base.encode16(case: :upper)

    "#{prefijo}-#{aleatorio}"
  end
end
