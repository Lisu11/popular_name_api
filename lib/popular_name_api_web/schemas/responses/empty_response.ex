defmodule PopularNameApiWeb.Schemas.EmptyResponse do
  @moduledoc """
  empty response
  """
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "EmptyResponse",
    description: "An empty response schema",
    type: :object,
    properties: %{}
  })
end
