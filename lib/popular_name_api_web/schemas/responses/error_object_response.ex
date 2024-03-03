defmodule PopularNameApiWeb.Schemas.ErrorObjectResponse do
  @moduledoc """
  The default error response
  """
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ErrorObjectResponse",
    description:
      "A response with errors. The errors object is a key/value index where the key is the variable and the value is an array of messages.",
    type: :object,
    properties: %{
      error_details: %Schema{type: :object, additionalProperties: true}
    }
  })
end
