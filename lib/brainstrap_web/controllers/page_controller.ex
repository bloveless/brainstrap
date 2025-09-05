defmodule BrainstrapWeb.PageController do
  use BrainstrapWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
