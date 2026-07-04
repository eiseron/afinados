defmodule AfinadosWeb.HubLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Afinados.Offers.Offer
  alias Afinados.Repo

  defp create_offer(attrs) do
    base = %{
      locale: "pt_BR",
      title: "Curso de exemplo",
      target_url: "https://go.hotmart.com/example",
      surfaces: ["hub_shelf"]
    }

    %Offer{}
    |> Offer.changeset(Enum.into(attrs, base))
    |> Repo.insert!()
  end

  test "the hub lists the fuel-passage area tool linking to the simulator", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(href="/carburetion/setups")
  end

  test "the hub links the intake sizing tool to its page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(href="/carburetion/intake-sizing")
  end

  test "the hub announces the two-stroke exhaust sizing tool as coming soon", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(class="tool-card tool-card-soon")
    assert html =~ "Dimensionamento de escape 2 tempos"
  end

  test "the top bar offers a documentation link that opens the docs in a new tab", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~
             ~r{<a class="doc-link doc-link-icon" href="[^"]*docs[^"]*" target="_blank" rel="noopener noreferrer"}
  end

  test "the hub renders a hub-shelf offer as an affiliate-safe external card", %{conn: conn} do
    create_offer(
      title: "Curso de preparação 2 tempos",
      target_url: "https://go.hotmart.com/curso-2t",
      image_url: "https://cdn.example.com/curso-2t.png"
    )

    {:ok, _view, html} = live(conn, "/")

    assert html =~ "Curso de preparação 2 tempos"
    assert html =~ ~s(href="https://go.hotmart.com/curso-2t")
    assert html =~ ~s(rel="sponsored nofollow noopener external")
    assert html =~ ~s(src="https://cdn.example.com/curso-2t.png")
    assert html =~ ~s(<article class="offer-card">)
    assert html =~ ~s(class="offers-disclosure")
    assert html =~ ~s(aria-label="abre um site externo")
  end

  test "the hub renders an affiliate offer with a call to action", %{conn: conn} do
    create_offer(title: "Curso avançado")

    {:ok, _view, html} = live(conn, "/")

    assert html =~ "Ver produto"
  end

  test "an offer without an image renders a placeholder instead", %{conn: conn} do
    create_offer(title: "Curso sem imagem")

    {:ok, _view, html} = live(conn, "/")

    assert html =~ "offer-image-placeholder"
  end

  test "the hub hides offers targeted at another locale", %{conn: conn} do
    create_offer(locale: "en", title: "English-only tuning course")

    {:ok, _view, html} = live(conn, "/")

    refute html =~ "English-only tuning course"
  end

  test "the hub omits the offer shelf when no offer targets the surface", %{conn: conn} do
    create_offer(title: "Untagged offer", surfaces: [])

    {:ok, _view, html} = live(conn, "/")

    refute html =~ ~s(class="offers-disclosure")
  end
end
