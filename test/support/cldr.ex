defmodule DateTimeParser.Cldr do
  @moduledoc """
  Cldr module used in tests
  """
  use Cldr,
    locales: ["en", "pl"],
    default_locale: "en",
    providers: [Cldr.Calendar, Cldr.DateTime, Cldr.Number]
end
