defmodule BrainstrapWeb.TrailHTML do
  use BrainstrapWeb, :html

  embed_templates "trail_html/*"

  @doc """
  Renders a trail form.

  The form is defined in the template at
  trail_html/trail_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def trail_form(assigns)
end
