defmodule Hackaton.Adapter.BaseDatos.BdMensaje do
  @moduledoc """
    Módulo encargado de gestionar la persistencia de mensajes en el sistema.

    Los mensajes se almacenan en un archivo CSV y este módulo permite:

      - Leer todos los mensajes.
      - Buscar un mensaje por ID.
      - Registrar nuevos mensajes.
      - Actualizar mensajes existentes.
      - Eliminar mensajes.
      - Filtrar mensajes según distintos criterios (proyecto, equipo, sala, etc.).

    Cada registro del archivo CSV debe tener el siguiente formato:
  id,Tipo_mensaje,Tipo_receptor,id_receptor,id_emisor,Contenido,id_equipo,Fecha,id_proyecto,Estado
  """

  alias Hackaton.Domain.Mensaje

  @doc """
  Lee todos los mensajes almacenados en `nombre_archivo`.

  - Ignora la fila de cabecera.
  - Convierte cada fila válida en un struct `%Mensaje{}`.
  - Transforma los campos `tipo_mensaje` y `tipo_receptor` a átomos.
  - Filtra entradas vacías o inválidas.


  """
  def leer_mensajes(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            [
              "id",
              "Tipo_mensaje",
              "Tipo_receptor",
              "id_receptor",
              "id_emisor",
              "Contenido",
              "id_equipo",
              "Fecha",
              "id_proyecto",
              "Estado"
            ] ->
              nil

            [
              id,
              tipo_mensaje,
              tipo_receptor,
              id_receptor,
              id_emisor,
              contenido,
              id_equipo,
              fecha,
              id_proyecto,
              estado
            ] ->
              %Mensaje{
                id: id,
                tipo_mensaje: String.to_atom(tipo_mensaje),
                tipo_receptor: String.to_atom(tipo_receptor),
                id_receptor: id_receptor,
                id_emisor: id_emisor,
                contenido: contenido,
                id_equipo: id_equipo,
                fecha: fecha,
                id_proyecto: id_proyecto,
                estado: estado
              }

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("No se puedo realizar por #{reason}")
        []
    end
  end

  @doc """
  Busca un único mensaje por su ID (`id_mensaje`).

  - Lee todas las líneas del archivo.
  - Convierte solo la coincidencia exacta en un struct `%Mensaje{}`.

  """
  def leer_mensaje(nombre_archivo, id_mensaje) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Tipo_mensaje",
                "Tipo_receptor",
                "id_receptor",
                "id_emisor",
                "Contenido",
                "id_equipo",
                "Fecha",
                "id_proyecto",
                "Estado"
              ] ->
                nil

              [
                id,
                tipo_mensaje,
                tipo_receptor,
                id_receptor,
                id_emisor,
                contenido,
                id_equipo,
                fecha,
                id_proyecto,
                estado
              ] ->
                if id == id_mensaje do
                  %Mensaje{
                    id: id,
                    tipo_mensaje: String.to_atom(tipo_mensaje),
                    tipo_receptor: String.to_atom(tipo_receptor),
                    id_receptor: id_receptor,
                    id_emisor: id_emisor,
                    contenido: contenido,
                    id_equipo: id_equipo,
                    fecha: fecha,
                    id_proyecto: id_proyecto,
                    estado: estado
                  }
                else
                  nil
                end

              _ ->
                nil
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [mensaje | _] -> mensaje
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("No se puedo realizar por  #{reason}")
        nil
    end
  end

  @doc """
  Escribe un nuevo mensaje en el archivo CSV.

  Se agrega una nueva línea con el formato:
  id,tipo_mensaje,tipo_receptor,id_receptor,id_emisor,contenido,id_equipo,fecha,id_proyecto,estado

  """
  def escribir_mensaje(
        nombre_archivo,
        %Mensaje{
          id: id,
          tipo_mensaje: tipo_mensaje,
          tipo_receptor: tipo_receptor,
          id_receptor: id_receptor,
          id_emisor: id_emisor,
          contenido: contenido,
          id_equipo: id_equipo,
          fecha: fecha,
          id_proyecto: id_proyecto,
          estado: estado
        }
      ) do
    File.write(
      nombre_archivo,
      "\n#{id},#{Atom.to_string(tipo_mensaje)},#{Atom.to_string(tipo_receptor)},#{id_receptor},#{id_emisor},#{String.replace(contenido, ",", "")},#{id_equipo},#{fecha},#{id_proyecto},#{estado}",
      [:append, :utf8]
    )
  end

  @doc """
  Elimina un mensaje del archivo según su ID (`id_a_borrar`).

  - Lee todas las líneas.
  - Excluye la que coincide con el ID.
  - Escribe nuevamente el archivo.

  """
  def borrar_mensaje(nombre_archivo, id_a_borrar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lineas = String.split(lista, "\n", trim: true)
        [cabecera | datos] = lineas

        nuevos_datos =
          Enum.reject(datos, fn linea ->
            case String.split(linea, ",") do
              [id | _resto] -> id == id_a_borrar
              _ -> false
            end
          end)

        nuevo_contenido = Enum.join([cabecera | nuevos_datos], "\n")

        case File.write(nombre_archivo, nuevo_contenido, [:utf8]) do
          :ok ->
            IO.puts("Mensaje con id #{id_a_borrar} eliminado correctamente.")
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

  @doc """
  Actualiza un mensaje reemplazando el existente por `mensaje_nuevo`.

  Funcionamiento:

  1. Elimina el mensaje existente por ID.
  2. Escribe el nuevo mensaje.
  """
  def actualizar_mensaje(nombre_archivo, mensaje_nuevo) do
    borrar_mensaje(nombre_archivo, mensaje_nuevo.id)
    escribir_mensaje(nombre_archivo, mensaje_nuevo)
  end

  @doc """
  Filtra mensajes por tipo (`tipo_buscar`) y proyecto (`id_proyecto_buscar`).

  """
  def filtrar_mensajes_proyecto(nombre_archivo, tipo_buscar, id_proyecto_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar and mensaje.id_proyecto == id_proyecto_buscar
    end)
  end

  @doc """
  Filtra mensajes personales entre un emisor y un receptor específico.
  """
  def filtrar_mensajes_personal(nombre_archivo, id_emisor_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_emisor == id_emisor_buscar and mensaje.id_receptor == id_receptor_buscar
    end)
  end

  @doc """
  Igual que `filtrar_mensajes_personal/3`, pero solo devuelve los mensajes en estado `"pendiente"`.
  """
  def filtrar_mensajes_personal_pendiente(nombre_archivo, id_emisor_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_emisor == id_emisor_buscar and mensaje.id_receptor == id_receptor_buscar and
        mensaje.estado == "pendiente"
    end)
  end

  @doc """
  Filtra mensajes enviados a un equipo (`id_equipo`).
  """
  def filtrar_mensajes_equipo(nombre_archivo, id_equipo) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_equipo == id_equipo
    end)
  end

  @doc """
  Igual que `filtrar_mensajes_equipo/2`, pero solo mensajes `"pendiente"`.
  """
  def filtrar_mensajes_equipo_pendiente(nombre_archivo, id_equipo) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_equipo == id_equipo and mensaje.estado == "pendiente"
    end)
  end

  @doc """
  Filtra consultas entre un mentor (`id_mentor`) y un equipo (`id_equipo`),
  mostrando únicamente las pendientes.
  """
  def filtrar_consultas_equipo_mentor_pendiente(nombre_archivo, id_equipo, id_mentor) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      (mensaje.id_receptor == id_mentor or mensaje.id_emisor == id_mentor) and
        mensaje.id_equipo == id_equipo and
        mensaje.tipo_mensaje == :consulta and
        mensaje.estado == "pendiente"
    end)
  end

  @doc """
  Igual que `filtrar_consultas_equipo_mentor_pendiente/3`,
  pero sin filtrar por estado.
  """
  def filtrar_consultas_equipo_mentor(nombre_archivo, id_equipo, id_mentor) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      (mensaje.id_receptor == id_mentor or mensaje.id_emisor == id_mentor) and
        mensaje.id_equipo == id_equipo and
        mensaje.tipo_mensaje == :consulta
    end)
  end

  @doc """
  Filtra mensajes dirigidos a una sala (`id_sala`).
  """
  def filtrar_mensajes_sala(nombre_archivo, id_sala) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_receptor == id_sala
    end)
  end

  @doc """
  Igual que `filtrar_mensajes_sala/2`, pero solo mensajes `"pendiente"`.
  """
  def filtrar_mensajes_sala_pendiente(nombre_archivo, id_sala) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_receptor == id_sala and mensaje.estado == "pendiente"
    end)
  end

  @doc """
  Filtra mensajes según su tipo (`:avance`, `:chat`, :consulta`,
  `:retroalimentacion`, `:anuncio`).
  """
  def filtrar_mensajes(nombre_archivo, tipo_buscar)
      when tipo_buscar in [:avance, :chat, :consulta, :retroalimentacion, :anuncio] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar
    end)
  end

  @doc """
  Filtra mensajes según el tipo de receptor (`:equipo`, `:sala`, `:usuario`, `:todos`).
  """
  def filtrar_mensajes(nombre_archivo, tipo_receptor)
      when tipo_receptor in [:equipo, :sala, :usuario, :todos] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_receptor == tipo_receptor
    end)
  end

  @doc """
  Filtra mensajes por tipo (`tipo_buscar`) y receptor (`id_receptor_buscar`).
  """
  def filtrar_mensajes(nombre_archivo, tipo_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar and mensaje.id_receptor == id_receptor_buscar
    end)
  end
end
