defmodule PopularNameApiWeb.Schemas.ErrorStringResponse do
    @moduledoc """
    The default error response
    """
    alias OpenApiSpex.Schema
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ErrorStringResponse",
      description:
        "A response with error. The error_details is a string message.",
      type: :object,
      properties: %{
        error_details: %Schema{
          type: :string,
          description: "Error details"
        }
      }
    })
  end
