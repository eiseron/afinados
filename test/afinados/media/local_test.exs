defmodule Afinados.Media.LocalTest do
  use ExUnit.Case, async: true

  alias Afinados.Media.Local

  setup do
    dir = Path.join(System.tmp_dir!(), "afinados-media-#{System.unique_integer([:positive])}")
    previous = Application.get_env(:afinados, Afinados.Media.Local)
    Application.put_env(:afinados, Afinados.Media.Local, dir: dir)

    on_exit(fn ->
      Application.put_env(:afinados, Afinados.Media.Local, previous)
      File.rm_rf!(dir)
    end)

    %{dir: dir}
  end

  test "returns a public /uploads url for the stored object" do
    {:ok, url} = Local.put("offers/abc.png", "png-bytes", "image/png")

    assert url =~ ~r{^https?://.+/uploads/offers/abc\.png$}
  end

  test "writes the uploaded bytes under the uploads dir", %{dir: dir} do
    Local.put("offers/abc.png", "png-bytes", "image/png")

    assert {:ok, "png-bytes"} = :file.read_file(Path.join(dir, "offers/abc.png"))
  end
end
