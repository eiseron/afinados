defmodule AfinadosWeb.ErrorJSONTest do
  use AfinadosWeb.ConnCase, async: true

  test "renders 404" do
    assert AfinadosWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AfinadosWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
