defmodule Hackaton.Adapter.BaseDatos.BdProyecto do
  alias Hackaton.Domain.Proyecto
  def leer_proyectos(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(String.replace(linea, "\r", ""), ",") do
          ["id","Nombre","Descripción","Categoria","Estado","id_equipo","Fecha_creacion"] -> nil
          [id,nombre,descripcion,categoria,estado,id_equipo,fecha_creacion] ->
            %Proyecto{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria, estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
          _ -> nil
        end
      end)
      |> Enum.filter(fn x -> x  end)

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        nil
    end
  end

  def leer_proyecto(nombre_archivo, id_proyecto) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(String.replace(linea, "\r", ""), ",") do
          ["id","Nombre","Descripción","Categoria","Estado","id_equipo","Fecha_creacion"] -> nil
          [id,nombre,descripcion,categoria,estado,id_equipo,fecha_creacion] ->
          if id == id_proyecto do
           %Proyecto{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria, estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
          else
            nil
          end
          _ -> []
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [proyecto| _] -> proyecto
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def leer_proyecto_nombre(nombre_archivo, nombre_) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(String.replace(linea, "\r", ""), ",") do
          ["id","Nombre","Descripción","Categoria","Estado","id_equipo","Fecha_creacion"] -> nil
          [id,nombre,descripcion,categoria,estado,id_equipo,fecha_creacion] ->
          if nombre_ == nombre do
           %Proyecto{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria, estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
          else
            nil
          end
          _ -> []
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [proyecto| _] -> proyecto
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

    def leer_proyecto_id_equipo(nombre_archivo, id_equipo_) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre","Descripción","Categoria","Estado","id_equipo","Fecha_creacion"] -> nil
          [id,nombre,descripcion,categoria,estado,id_equipo,fecha_creacion] ->
          if id_equipo == id_equipo_ do
           %Proyecto{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria, estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
          else
            nil
          end
          _ -> []
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [proyecto| _] -> proyecto
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def borrar_proyecto(nombre_archivo, id_a_borrar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lineas = String.split(lista, "\n", trim: true)

        [cabecera | datos] = lineas

        nuevos_datos =
          datos
          |> Enum.reject(fn linea ->
            case String.split(linea, ",") do
              [id | _resto] -> id == id_a_borrar
              _ -> false
            end
          end)

        nuevo_contenido = Enum.join([cabecera | nuevos_datos], "\n")

        case File.write(nombre_archivo, nuevo_contenido, [:utf8]) do
          :ok ->
            IO.puts("Proyecto con id #{id_a_borrar} eliminado correctamente.")
            :ok

          {:error, reason} ->
            IO.puts("Error al escribir archivo: #{reason}")
            {:error, reason}
        end

      {:error, reason} ->
        IO.puts("Error al leer archivo: #{reason}")
        {:error, reason}
    end
  end

  def escribir_proyecto(nombre_archivo, %Proyecto{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria, estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}) do
    File.write(nombre_archivo, "\n#{id},#{nombre},#{descripcion},#{categoria},#{estado},#{id_equipo},#{fecha_creacion}", [:append, :utf8])
  end

  def actualizar_proyecto(nombre_archivo, proyecto) do
    borrar_proyecto(nombre_archivo, proyecto.id)
    escribir_proyecto(nombre_archivo, proyecto)
  end

end
