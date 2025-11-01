defmodule BrainstrapWeb.Controller do
  defmacro __using__(_) do
    quote do
      use BrainstrapWeb, :controller

      def action(conn, _), do: BrainstrapWeb.Controller.__action__(__MODULE__, conn)
      defoverridable action: 2
    end
  end

  def __action__(controller, conn) do
    args = [conn, conn.params, conn.assigns.current_scope.user || :guest]
    apply(controller, Phoenix.Controller.action_name(conn), args)
  end
end
