defmodule PopularNameApiWeb.ErrorJSONTest do
  use PopularNameApiWeb.ConnCase, async: true

  test "renders 404" do
    assert PopularNameApiWeb.ErrorJSON.render("404.json", %{}) == %{error_details: "Not Found"}
  end

  test "renders 500" do
    assert PopularNameApiWeb.ErrorJSON.render("500.json", %{}) ==
             %{error_details: "Internal Server Error"}
  end
end
