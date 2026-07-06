defmodule Afinados.Media.R2Test do
  use ExUnit.Case, async: true

  alias Afinados.Media.R2

  defp configure(plug) do
    previous = Application.get_env(:afinados, Afinados.Media.R2)

    Application.put_env(:afinados, Afinados.Media.R2,
      bucket: "afinados-media",
      endpoint: "https://acct.r2.cloudflarestorage.com",
      access_key_id: "access-key",
      secret_access_key: "secret-key",
      public_base_url: "https://img.afinados.io",
      req_options: [plug: plug, retry: false]
    )

    on_exit(fn -> Application.put_env(:afinados, Afinados.Media.R2, previous) end)
  end

  test "returns the object public url on a successful put" do
    configure(fn conn -> Plug.Conn.send_resp(conn, 200, "") end)

    assert {:ok, "https://img.afinados.io/offers/abc.png"} =
             R2.put("offers/abc.png", "png-bytes", "image/png")
  end

  test "PUTs the object to the bucket path signed with AWS SigV4" do
    test_pid = self()

    configure(fn conn ->
      send(
        test_pid,
        {:request, conn.method, conn.request_path,
         Plug.Conn.get_req_header(conn, "authorization")}
      )

      Plug.Conn.send_resp(conn, 200, "")
    end)

    R2.put("offers/abc.png", "png-bytes", "image/png")

    assert_received {:request, "PUT", "/afinados-media/offers/abc.png", ["AWS4-HMAC-SHA256" <> _]}
  end

  test "returns an error tuple on a non-2xx response" do
    configure(fn conn -> Plug.Conn.send_resp(conn, 500, "boom") end)

    assert {:error, {:unexpected_status, 500, "boom"}} =
             R2.put("offers/abc.png", "png-bytes", "image/png")
  end
end
