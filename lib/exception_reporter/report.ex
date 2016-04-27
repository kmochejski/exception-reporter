defmodule ExceptionReporter.Report do
  defstruct(
    timestamp: nil,
    server: nil,
    request: %{
      path: nil,
      method: nil,
      parameters: %{},
      ip_address: nil,
      headers: []
    },
    kind: nil,
    reason: nil,
    stack: []
  )
end
