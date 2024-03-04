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
    alias PopularNameApi.Citizens

    test "that lists all persons rerurns empty list", %{conn: conn} do
      conn = get(conn, ~p"/api/persons")
      assert json_response(conn, 200)["data"] == []
    end

    test "that lists all persons returns non empty list", %{conn: conn} do
      insert_list(10, :person)
      conn = get(conn, ~p"/api/persons")
      assert response(conn, 200)
      assert Enum.count(json_response(conn, 200)["data"]) == 10
    end

    test "that lists all persons allows filtering by birth date", %{conn: conn} do
      [p | _] = insert_list(10, :person)
      assert Enum.count(Citizens.list_persons()) == 10

      conn =
        get(conn, ~p"/api/persons",
          birth_date_from: Date.add(p.birth_date, 5),
          birth_date_to: Date.add(p.birth_date, 8)
        )

      assert response(conn, 200)
      assert Enum.count(json_response(conn, 200)["data"]) == 4
    end

    test "that lists all persons allows filtering by sex", %{conn: conn} do
      insert_list(10, :person)
      insert_list(10, :person, %{sex: :male})

      conn = get(conn, ~p"/api/persons", sex: :male)
      assert response(conn, 200)
      assert Enum.count(json_response(conn, 200)["data"]) == 10
    end

    test "that lists all persons allows filtering by first_name", %{conn: conn} do
      insert_list(10, :person)
      insert_list(10, :person, %{first_name: "John", sex: :male})

      conn = get(conn, ~p"/api/persons", first_name: "John")
      assert response(conn, 200)
      assert Enum.count(json_response(conn, 200)["data"]) == 10
    end

    test "that lists all persons allows sorting by first_name ascending and last_name descending",
         %{conn: conn} do
      insert(:person, %{first_name: "John", sex: :male})
      insert(:person, %{first_name: "John", last_name: "Anderson", sex: :male})
      insert(:person, %{first_name: "Jacob", sex: :male})
      insert(:person, %{first_name: "Abraham", sex: :male})

      conn = get(conn, ~p"/api/persons", sort: "asc(first_name),desc(last_name)")
      assert response(conn, 200)

      result =
        json_response(conn, 200)["data"] |> Enum.map(&Map.take(&1, ["first_name", "last_name"]))

      assert result == [
               %{"first_name" => "Abraham", "last_name" => "Smith"},
               %{"first_name" => "Jacob", "last_name" => "Smith"},
               %{"first_name" => "John", "last_name" => "Smith"},
               %{"first_name" => "John", "last_name" => "Anderson"}
             ]
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
