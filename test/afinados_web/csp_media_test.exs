defmodule AfinadosWeb.CspMediaTest do
  use AfinadosWeb.ConnCase, async: false

  test "the response CSP allows the configured media host for images", %{conn: conn} do
    original = Application.get_env(:afinados, Afinados.Media.R2)
    Application.put_env(:afinados, Afinados.Media.R2, public_base_url: "https://img.afinados.io")

    on_exit(fn ->
      if original do
        Application.put_env(:afinados, Afinados.Media.R2, original)
      else
        Application.delete_env(:afinados, Afinados.Media.R2)
      end
    end)

    conn = get(conn, "/")

    assert hd(get_resp_header(conn, "content-security-policy")) =~
             ~r{img-src[^;]*https://img\.afinados\.io}
  end
end
