defmodule AfinadosWeb.CoreComponents do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: AfinadosWeb.Gettext

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  attr(:id, :string, doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")
  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      {@rest}
    >
      <button
        type="button"
        class="flash-close"
        phx-click={JS.hide(to: "##{@id}")}
        aria-label={gettext("Close")}
      >
        ×
      </button>
      <p :if={@title}>{@title}</p>
      <p>{msg}</p>
    </div>
    """
  end

  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")

  attr(:rest, :global, include: ~w(accept autocomplete disabled form max maxlength min minlength
                pattern placeholder readonly required rows size step))

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Form.normalize_value("checkbox", assigns[:value]) end)

    ~H"""
    <label>
      <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
      <input type="checkbox" id={@id} name={@name} value="true" checked={@checked} {@rest} />
      {@label}
    </label>
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <.label :if={@label} for={@id}>{@label}</.label>
    <select id={@id} name={@name} multiple={@multiple} {@rest}>
      <option :if={@prompt} value="">{@prompt}</option>
      {Form.options_for_select(@options, @value)}
    </select>
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <.label :if={@label} for={@id}>{@label}</.label>
    <textarea id={@id} name={@name} {@rest}>{Form.normalize_value("textarea", @value)}</textarea>
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  def input(assigns) do
    ~H"""
    <.label :if={@label} for={@id}>{@label}</.label>
    <input type={@type} name={@name} id={@id} value={Form.normalize_value(@type, @value)} {@rest} />
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for}>{render_slot(@inner_block)}</label>
    """
  end

  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p>{render_slot(@inner_block)}</p>
    """
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js, to: selector, time: 200)
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js, to: selector, time: 200)
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(AfinadosWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AfinadosWeb.Gettext, "errors", msg, opts)
    end
  end

  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
