defmodule DateTimeParser.TimezoneAbbreviations do
  @moduledoc """
  Fetch timezone information by name or by abbreviations. This is designed
  to power parsing strings with timezone appreviations in them.
  """

  {zones, rules} = DateTimeParser.TimezoneParser.parse()
  @zones zones
  @rules rules

  def rules, do: @rules
  def zones, do: @zones

  def rules(name), do: Enum.filter(rules(), &(&1.name == name))

  def zones_by_name(name, date \\ DateTime.utc_now()) do
    Enum.find(zones(), fn candidate_zone ->
      (candidate_zone.name == name or name in candidate_zone.aliases) &&
        within_rule_timespan(candidate_zone.from, candidate_zone.until, date)
    end)
  end

  def zones_by_abbreviation(abbreviation, date \\ DateTime.utc_now()) do
    Enum.filter(zones(), fn candidate_zone ->
      abbreviation in candidate_zone.abbreviations &&
        within_rule_timespan(candidate_zone.from, candidate_zone.until, date)
    end)
  end

  defp within_rule_timespan(from, until, date) do
    case {from, until} do
      {nil, nil} ->
        true

      {nil, until} ->
        NaiveDateTime.compare(until, date) == :gt

      {from, nil} ->
        NaiveDateTime.compare(from, date) == :lt

      {from, until} ->
        NaiveDateTime.compare(from, date) == :lt &&
          NaiveDateTime.compare(until, date) == :gt
    end
  end
end
