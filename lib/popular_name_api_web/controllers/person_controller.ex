defmodule PopularNameApiWeb.PersonController do
  use PopularNameApiWeb, :controller

  alias PopularNameApi.Citizens
  alias PopularNameApi.Citizens.Person

  action_fallback PopularNameApiWeb.FallbackController

  def index(conn, _params) do
    persons = Citizens.list_persons()
    render(conn, :index, persons: persons)
  end

  def create(conn, %{"person" => person_params}) do
    with {:ok, %Person{} = person} <- Citizens.create_person(person_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/persons/#{person}")
      |> render(:show, person: person)
    end
  end

  def show(conn, %{"id" => id}) do
    person = Citizens.get_person!(id)
    render(conn, :show, person: person)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = Citizens.get_person!(id)

    with {:ok, %Person{} = person} <- Citizens.update_person(person, person_params) do
      render(conn, :show, person: person)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Citizens.get_person!(id)

    with {:ok, %Person{}} <- Citizens.delete_person(person) do
      send_resp(conn, :no_content, "")
    end
  end
end
