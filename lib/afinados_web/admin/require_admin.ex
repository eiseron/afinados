defmodule AfinadosWeb.Admin.RequireAdmin do
  @moduledoc """
  on_mount hook enforcing admin access on the live socket, mirroring
  `AfinadosWeb.AdminAccessPlug`. When the gate is enabled, the mount only
  continues if the session was authenticated by the plug; otherwise it halts.
  When the gate is disabled (dev/preview), the host Access is the protection and
  the mount continues.
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [redirect: 2]

  def on_mount(:default, _params, session, socket) do
    config = Application.get_env(:afinados, AfinadosWeb.AdminAccessPlug, [])

    cond do
      not Keyword.get(config, :enabled, false) ->
        {:cont, socket}

      is_binary(session["admin_email"]) ->
        {:cont, assign(socket, :admin_email, session["admin_email"])}

      true ->
        {:halt, redirect(socket, to: "/")}
    end
  end
end
