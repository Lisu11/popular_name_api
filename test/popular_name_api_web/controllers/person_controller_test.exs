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

  describe "generate" do
    alias PopularNameApi.Citizens

    test "generate some persons", %{conn: conn} do
      assert Citizens.list_persons() == []

      conn = post(conn, ~p"/api/generate")
      assert response(conn, 204)
      :timer.sleep(1500)

      assert Enum.count(Citizens.list_persons()) == 100
    end
  end

  describe "index" do
    test "lists all persons", %{conn: conn} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create person" do
    test "renders person when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/persons", Map.to_list(@create_attrs))
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
      conn = post(conn, ~p"/api/persons", Map.to_list(@invalid_attrs))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update person" do
    setup [:create_person]

    test "renders person when data is valid", %{conn: conn, person: %Person{id: id} = person} do
      conn = put(conn, ~p"/api/persons/#{person}", Map.to_list(@update_attrs))
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
      conn = put(conn, ~p"/api/persons/#{person.id}", Map.to_list(@invalid_attrs))
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "bad request should be return for invalid id", %{conn: conn} do
      conn = put(conn, ~p"/api/persons/abc", Map.to_list(@update_attrs))
      assert response(conn, 400)
      assert json_response(conn, 400)["error_details"] =~ "Bad Request"
    end

    test "not found should be return for unknown id", %{conn: conn, person: person} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"]
      [p] = json_response(conn, 200)["data"]
      assert p["id"] == person.id

      conn = put(conn, ~p"/api/persons/#{person.id + 1}", Map.to_list(@update_attrs))
      assert json_response(conn, 404)["error_details"] =~ "Not Found"
    end
  end

  describe "show person" do
    setup [:create_person]

    test "shows chosen person", %{conn: conn, person: person} do
      conn = get(conn, ~p"/api/persons/#{person.id}")
      assert response(conn, 200)
      p = json_response(conn, 200)["data"]

      assert p["id"] == person.id
      assert p["first_name"] == person.first_name
      assert p["last_name"] == person.last_name
    end

    test "bad request should be return for invalid id", %{conn: conn} do
      conn = get(conn, ~p"/api/persons/abc")
      assert response(conn, 400)
      assert json_response(conn, 400)["error_details"] =~ "Bad Request"
    end

    test "not found should be return for unknown id", %{conn: conn, person: person} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"]
      [p] = json_response(conn, 200)["data"]
      assert p["id"] == person.id

      conn = get(conn, ~p"/api/persons/#{person.id + 1}")
      assert json_response(conn, 404)["error_details"] =~ "Not Found"
    end
  end

  describe "delete person" do
    setup [:create_person]

    test "deletes chosen person", %{conn: conn, person: person} do
      conn = delete(conn, ~p"/api/persons/#{person.id}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/persons/#{person.id}")
      assert response(conn, 404)
    end

    test "bad request should be return for invalid id", %{conn: conn} do
      conn = delete(conn, ~p"/api/persons/abc")
      assert response(conn, 400)
      assert json_response(conn, 400)["error_details"] =~ "Bad Request"
    end

    test "not found should be return for unknown id", %{conn: conn, person: person} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"]
      [p] = json_response(conn, 200)["data"]
      assert p["id"] == person.id

      conn = delete(conn, ~p"/api/persons/#{person.id + 1}")
      assert json_response(conn, 404)["error_details"] =~ "Not Found"
    end
  end

  defp create_person(_) do
    person = insert(:person)
    %{person: person}
  end
end
