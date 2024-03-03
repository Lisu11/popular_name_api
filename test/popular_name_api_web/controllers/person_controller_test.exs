defmodule PopularNameApiWeb.PersonControllerTest do
  use PopularNameApiWeb.ConnCase


  alias PopularNameApi.Citizens.Person

  @create_attrs %{
    first_name: "Julia",
    last_name: "Smith",
    sex: "female",
    birth_date: ~D[1999-01-01]
  }
  @update_attrs %{
    first_name: "Julian",
    last_name: "Smith",
    sex: "male",
    birth_date: ~D[2002-01-01]
  }
  @invalid_attrs %{first_name: nil, last_name: nil, sex: nil, birth_date: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all persons", %{conn: conn} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create person" do
    test "renders person when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/persons", person: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/persons/#{id}")

      assert %{
               "id" => ^id,
               "first_name" => "Julia",
               "last_name" => "Smith",
               "birth_date" => "1999-01-01",
               "sex" => "female"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/persons", person: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update person" do
    setup [:create_person]

    test "renders person when data is valid", %{conn: conn, person: %Person{id: id} = person} do
      conn = put(conn, ~p"/api/persons/#{person}", person: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/persons/#{id}")

      assert %{
               "id" => ^id,
               "first_name" => "Julian",
               "last_name" => "Smith",
               "birth_date" => "2002-01-01",
               "sex" => "male"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, person: person} do
      conn = put(conn, ~p"/api/persons/#{person}", person: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete person" do
    setup [:create_person]

    test "deletes chosen person", %{conn: conn, person: person} do
      conn = delete(conn, ~p"/api/persons/#{person}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/persons/#{person}")
      end
    end
  end

  defp create_person(_) do
    person = insert(:person)
    %{person: person}
  end
end
