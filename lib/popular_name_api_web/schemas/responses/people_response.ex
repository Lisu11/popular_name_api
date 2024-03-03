 defmodule PopularNameApiWeb.Schemas.PeopleResponse do
  alias OpenApiSpex.Schema
  alias PopularNameApiWeb.Schemas.Person
  require OpenApiSpex

  OpenApiSpex.schema(%{
      title: "PeopleResponse",
      description: "Response schema for multiple persons",
      type: :object,
      properties: %{
        data: %Schema{type: :array, items: Person}
      },
      example: %{
        "data" => [%{
          "id" => 666,
          "first_name" => "Thomas",
          "last_name" => "Anderson",
          "birth_date" => "1970-01-01",
          "sex" => "male",
          "inserted_at" => "2017-09-12T12:34:55Z",
          "updated_at" => "2017-09-13T10:11:12Z"
        }]
      }
    })
  end
