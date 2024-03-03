defmodule PopularNameApiWeb.PersonController do
  use PopularNameApiWeb, :controller

  alias PopularNameApi.Citizens
  alias PopularNameApi.Citizens.Person

  alias PopularNameApiWeb.Schemas.{
    PeopleResponse,
    FilterParams,
    PersonParams,
    PersonResponse,
    ErrorObjectResponse,
    ErrorStringResponse,
    EmptyResponse
  }

  action_fallback PopularNameApiWeb.FallbackController

  tags ["persons"]

  operation :generate,
    summary: "Generate random people",
    parameters: [
      amount: [in: :query, type: :integer, description: "amount by default it is 100"]
    ],
    required: [],
    responses: %{
      204 => {"Generation started", "application/json", EmptyResponse}
    }

  def generate(conn, params) do
    params
    |> Map.get("amount", 100)
    |> PopularNameApi.PeopleGenerator.async_generation()

    send_resp(conn, :no_content, "")
  end

  operation :index,
    summary: "List generated people",
    parameters: [
      filter: [in: :query, type: FilterParams],
      sort: [in: :query, type: :string, description: "Example: asc(first_name),desc(birth_date)"]
    ],
    responses: %{
      :ok => {"People response", "application/json", PeopleResponse},
      400 => {"Wrong input data", "application/json", ErrorStringResponse}
    }

  def index(conn, %{"sort" => sorters} = params) do
    with true <- validate_sorters(sorters),
         parsed_sorters <- parse_sorters(sorters) do
      persons = Citizens.list_filtered_persons(params, parsed_sorters)
      render(conn, :index, persons: persons)
    end
  end

  def index(conn, params) do
    persons = Citizens.list_filtered_persons(params, [])
    render(conn, :index, persons: persons)
  end

  defp validate_sorters(sorters) do
    sorters
    |> String.split(",")
    |> Enum.all?(fn col ->
      col =~
        ~r/(asc\((first_name)|(last_name)|(birth_date)|(sex)\))|(desc\((first_name)|(last_name)|(birth_date)|(sex)\))/
    end)
    |> case do
      false -> {:error, :bad_request}
      true -> true
    end
  end

  defp parse_sorters(sorters) do
    sorters
    |> String.split(",")
    |> Enum.map(fn
      "asc(" <> field ->
        field
        |> String.trim_trailing(")")
        |> then(&{String.to_existing_atom(&1), :asc})

      "desc(" <> field ->
        field
        |> String.trim_trailing(")")
        |> then(&{String.to_existing_atom(&1), :desc})
    end)
  end

  operation :create,
    summary: "Create one person",
    request_body: {"Persons params", "application/json", PersonParams},
    responses: %{
      :ok => {"Person response", "application/json", PersonResponse},
      422 => {"Wrong input", "application/json", ErrorObjectResponse}
    }

  def create(conn, person_params) do
    with {:ok, %Person{} = person} <- Citizens.create_person(person_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/persons/#{person}")
      |> render(:show, person: person)
    end
  end

  operation :show,
    summary: "Show one person for a specific id",
    parameters: [
      id: [in: :path, type: :integer, description: "record ID"]
    ],
    responses: %{
      :ok => {"Person response", "application/json", PersonResponse},
      404 => {"Not found record for a given id", "application/json", ErrorStringResponse},
      400 => {"Wrong id input", "application/json", ErrorStringResponse}
    }

  def show(conn, %{"id" => id}) do
    with %Person{} = person <- validate_id_param(id) do
      render(conn, :show, person: person)
    end
  end

  operation :update,
    summary: "Update a person for a specific id",
    parameters: [
      id: [in: :path, type: :integer, description: "record ID"]
    ],
    request_body: {"Persons params", "application/json", PersonParams},
    responses: %{
      :ok => {"Person response", "application/json", PersonResponse},
      404 => {"Not found record for a given id", "application/json", ErrorStringResponse},
      400 => {"Wrong id input", "application/json", ErrorStringResponse},
      422 => {"Unprocessable Content", "application/json", ErrorObjectResponse}
    }

  def update(conn, %{"id" => id} = person_params) do
    with %Person{} = person <- validate_id_param(id),
         {:ok, %Person{} = person} <- Citizens.update_person(person, person_params) do
      render(conn, :show, person: person)
    end
  end

  operation :delete,
    summary: "delete person for a specific id",
    parameters: [
      id: [in: :path, type: :integer, description: "record ID"]
    ],
    responses: %{
      :ok => {"Person response", "application/json", EmptyResponse},
      404 => {"Not found record for a given id", "application/json", ErrorStringResponse},
      400 => {"Wrong id input", "application/json", ErrorStringResponse}
    }

  def delete(conn, %{"id" => id}) do
    with %Person{} = person <- validate_id_param(id),
         {:ok, %Person{}} <- Citizens.delete_person(person) do
      send_resp(conn, :no_content, "")
    end
  end

  defp validate_id_param(id) when is_binary(id) do
    with {id, ""} <- Integer.parse(id),
         %Person{} = person <- Citizens.get_person(id) do
      person
    else
      :error -> {:error, :bad_request}
      nil -> {:error, :not_found}
    end
  end
end
