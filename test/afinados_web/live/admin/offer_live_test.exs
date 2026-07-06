defmodule AfinadosWeb.Admin.OfferLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Afinados.Offers

  defp create_offer(attrs) do
    {:ok, offer} =
      Offers.create_offer(
        Map.merge(
          %{
            locale: "pt_BR",
            title: "Curso de carburação",
            target_url: "https://example.com/course",
            surfaces: ["hub_shelf"],
            position: 0,
            active: true
          },
          Map.new(attrs)
        )
      )

    offer
  end

  describe "Index" do
    test "lists existing offers", %{conn: conn} do
      create_offer(title: "Curso de carburação")

      {:ok, _view, html} = live(conn, ~p"/admin/offers")

      assert html =~ "Curso de carburação"
    end

    test "deletes an offer from the list", %{conn: conn} do
      offer = create_offer(title: "Removivel")

      {:ok, view, _html} = live(conn, ~p"/admin/offers")

      html =
        view
        |> element("button[phx-click='delete'][phx-value-id='#{offer.id}']")
        |> render_click()

      refute has_element?(view, "#offer-#{offer.id}")
      assert html =~ "Oferta excluída"
    end

    test "shows an error when deleting an already removed offer", %{conn: conn} do
      offer = create_offer(title: "Fantasma")

      {:ok, view, _html} = live(conn, ~p"/admin/offers")
      Offers.delete_offer(offer)

      html =
        view
        |> element("button[phx-click='delete'][phx-value-id='#{offer.id}']")
        |> render_click()

      assert html =~ "Could not delete offer" or html =~ "Não foi possível excluir a oferta"
    end

    test "flashes an error instead of crashing when delete receives a non-integer id", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/admin/offers")

      html = render_click(view, "delete", %{"id" => "abc"})

      assert has_element?(view, "[role='alert']") or
               html =~ "Could not delete offer" or
               html =~ "Não foi possível excluir a oferta"
    end
  end

  describe "Form new" do
    test "creates an offer and redirects to the list", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      params = %{
        "locale" => "pt_BR",
        "title" => "Carburador Nibbi PE28",
        "target_url" => "https://s.click.aliexpress.com/example",
        "surfaces" => ["hub_shelf"],
        "position" => "0",
        "active" => "true"
      }

      {:ok, _index, html} =
        view
        |> form("#offer-form", offer: params)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/offers")

      assert html =~ "Oferta criada"
      assert html =~ "Carburador Nibbi PE28"
    end

    test "renders validation errors for an invalid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      html =
        view
        |> form("#offer-form", offer: %{"title" => "", "locale" => "pt_BR"})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert Offers.list_offers() == []
    end
  end

  describe "Form preview" do
    test "renders a live card preview reflecting the form input", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      assert has_element?(view, "section.offer-preview .offer-card")

      view
      |> form("#offer-form",
        offer: %{
          "locale" => "pt_BR",
          "title" => "Carburador Nibbi PE28",
          "description" => "Reposição para preparação",
          "image_url" => "https://cdn.example/nibbi.jpg",
          "target_url" => "https://s.click.aliexpress.com/example"
        }
      )
      |> render_change()

      assert has_element?(view, ".offer-preview .offer-title", "Carburador Nibbi PE28")
      assert has_element?(view, ".offer-preview .offer-description", "Reposição para preparação")

      assert has_element?(
               view,
               ".offer-preview img.offer-image[src=\"https://cdn.example/nibbi.jpg\"]"
             )
    end

    test "shows the image placeholder in the preview when no image_url is set", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      view
      |> form("#offer-form", offer: %{"locale" => "pt_BR", "title" => "Sem imagem"})
      |> render_change()

      assert has_element?(view, ".offer-preview .offer-image-placeholder")
      assert has_element?(view, ".offer-preview .offer-title", "Sem imagem")
    end
  end

  describe "Form image upload" do
    test "uploads an image and stores its public url as the offer image_url", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      image =
        file_input(view, "#offer-form", :image, [
          %{name: "nibbi.png", content: "fake-png-bytes", type: "image/png"}
        ])

      assert render_upload(image, "nibbi.png")

      view
      |> form("#offer-form",
        offer: %{
          "locale" => "pt_BR",
          "title" => "Carburador Nibbi PE28",
          "target_url" => "https://s.click.aliexpress.com/example",
          "surfaces" => ["hub_shelf"],
          "position" => "0",
          "active" => "true"
        }
      )
      |> render_submit()

      offer = List.last(Offers.list_offers())
      assert offer.title == "Carburador Nibbi PE28"
      assert offer.image_url =~ ~r{^https://img\.test\.local/offers/[0-9a-f-]+\.png$}
    end

    test "cancels an uploaded entry before saving", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      image =
        file_input(view, "#offer-form", :image, [
          %{name: "nibbi.png", content: "fake-png-bytes", type: "image/png"}
        ])

      render_upload(image, "nibbi.png")
      assert has_element?(view, ".offer-upload-entry")

      view
      |> element("button[phx-click='cancel-upload']")
      |> render_click()

      refute has_element?(view, ".offer-upload-entry")
    end

    test "rejects a file whose type is not an accepted image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      image =
        file_input(view, "#offer-form", :image, [
          %{name: "notes.txt", content: "not an image", type: "text/plain"}
        ])

      assert {:error, [[_ref, :not_accepted]]} = render_upload(image, "notes.txt")
    end

    test "shows a friendly error message for an oversized image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      image =
        file_input(view, "#offer-form", :image, [
          %{name: "big.png", content: :binary.copy("x", 6_000_000), type: "image/png"}
        ])

      render_upload(image, "big.png")

      assert has_element?(view, ".offer-upload-error", "A imagem é muito grande")
    end

    test "shows a friendly error message when more than one image is added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/offers/new")

      image =
        file_input(view, "#offer-form", :image, [
          %{name: "a.png", content: "a", type: "image/png"},
          %{name: "b.png", content: "b", type: "image/png"}
        ])

      render_upload(image, "a.png")

      assert has_element?(view, ".offer-upload-error", "Apenas uma imagem é permitida")
    end
  end

  describe "Form edit" do
    test "updates an existing offer", %{conn: conn} do
      offer = create_offer(title: "Titulo antigo")

      {:ok, view, _html} = live(conn, ~p"/admin/offers/#{offer}/edit")

      {:ok, _index, html} =
        view
        |> form("#offer-form", offer: %{"title" => "Titulo novo"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/offers")

      assert html =~ "Oferta atualizada"
      assert html =~ "Titulo novo"
      refute html =~ "Titulo antigo"
    end

    test "redirects with error flash when edit receives a non-integer id", %{conn: conn} do
      {:ok, _index, html} =
        live(conn, ~p"/admin/offers/abc/edit")
        |> follow_redirect(conn, ~p"/admin/offers")

      assert html =~ "Offer not found" or html =~ "Oferta não encontrada"
    end
  end
end
