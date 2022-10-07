# DateTimeParser

[![Hex.pm Version](http://img.shields.io/hexpm/v/date_time_parser.svg)](https://hex.pm/packages/date_time_parser)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/date_time_parser)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](./CODE_OF_CONDUCT.md)

DateTimeParser is a tokenizer for strings that attempts to parse into a
DateTime, NaiveDateTime if timezone is not determined, Date, or Time.

You're currently looking at the main branch. [Check out the docs for the latest
published version.](https://hexdocs.pm/date_time_parser)

## Documentation

[See examples automatically generated by the tests](./EXAMPLES.md)

<!-- MDOC -->

The biggest ambiguity between datetime formats is whether it's `ymd` (year month
day), `mdy` (month day year), or `dmy` (day month year); this is resolved by
checking if there are slashes or dashes. If slashes, then it will try `dmy`
first. All other cases will use the international format `ymd`. Sometimes, if
the conditions are right, it can even parse `dmy` with dashes if the month is a
vocal month (eg, `"Jan"`).

If the string consists of only numbers, then we will try two other parsers
depending on the number of digits: [Epoch] or [Serial]. Otherwise, we'll try the
tokenizer.

If the string is 10-11 digits with optional precision, then we'll try to parse
it as a Unix [Epoch] timestamp.

If the string is 1-5 digits with optional precision, then we'll try to parse it
as a [Serial] timestamp (spreadsheet time) treating 1899-12-31 as 1. This will
cause Excel-produced dates from 1900-01-01 until 1900-03-01 to be incorrect, as
they really are.

|digits|parser|range|notes|
|---|----|---|---|
|1-5|Serial|low = `1900-01-01`, high = `2173-10-15`. Negative numbers go to `1626-03-17`|Floats indicate time. Integers do not.|
|6-9|Tokenizer|any|This allows for "20190429" to be parsed as `2019-04-29`|
|10-11|Epoch|low = `-1100-02-15 14:13:21`, high = `5138-11-16 09:46:39`|If padded with 0s, then it can capture entire range.|
|else|Tokenizer|any| |

[Epoch]: https://en.wikipedia.org/wiki/Unix_time
[Serial]: https://support.office.com/en-us/article/date-systems-in-excel-e7fe7167-48a9-4b96-bb53-5612a800b487

## Required reading

* [Elixir DateTime docs](https://hexdocs.pm/elixir/DateTime.html)
* [Elixir NaiveDateTime docs](https://hexdocs.pm/elixir/NaiveDateTime.html)
* [Elixir Date docs](https://hexdocs.pm/elixir/Date.html)
* [Elixir Time docs](https://hexdocs.pm/elixir/Time.html)
* [Elixir Calendar docs](https://hexdocs.pm/elixir/Calendar.html)

## Examples

```elixir
iex> DateTimeParser.parse("19 September 2018 08:15:22 AM")
{:ok, ~N[2018-09-19 08:15:22]}

iex> DateTimeParser.parse_datetime("19 September 2018 08:15:22 AM")
{:ok, ~N[2018-09-19 08:15:22]}

iex> DateTimeParser.parse_datetime("2034-01-13", assume_time: true)
{:ok, ~N[2034-01-13 00:00:00]}

iex> DateTimeParser.parse_datetime("2034-01-13", assume_time: ~T[06:00:00])
{:ok, ~N[2034-01-13 06:00:00]}

iex> DateTimeParser.parse("invalid date 10:30pm")
{:ok, ~T[22:30:00]}

iex> DateTimeParser.parse("2019-03-11T99:99:99")
{:ok, ~D[2019-03-11]}

iex> DateTimeParser.parse("2019-03-11T10:30:00pm UNK")
{:ok, ~N[2019-03-11T22:30:00]}

iex> DateTimeParser.parse("2019-03-11T22:30:00.234+00:00")
{:ok, DateTime.from_naive!(~N[2019-03-11T22:30:00.234Z], "Etc/UTC")}
# `~U[2019-03-11T22:30:00.234Z]` in Elixir 1.9+

iex> DateTimeParser.parse_date("2034-01-13")
{:ok, ~D[2034-01-13]}

iex> DateTimeParser.parse_date("01/01/2017")
{:ok, ~D[2017-01-01]}

iex> DateTimeParser.parse_datetime("1564154204")
{:ok, DateTime.from_naive!(~N[2019-07-26T15:16:44Z], "Etc/UTC")}
# `~U[2019-07-26T15:16:44Z]` in Elixir 1.9+

iex> DateTimeParser.parse_datetime("41261.6013888889")
{:ok, ~N[2012-12-18T14:26:00]}

iex> DateTimeParser.parse_date("44262")
{:ok, ~D[2021-03-07]}
# This is a serial number date, commonly found in spreadsheets, eg: `=VALUE("03/07/2021")`

iex> DateTimeParser.parse_datetime("1/1/18 3:24 PM")
{:ok, ~N[2018-01-01T15:24:00]}

iex> DateTimeParser.parse_datetime("1/1/18 3:24 PM", assume_utc: true)
{:ok, DateTime.from_naive!(~N[2018-01-01T15:24:00Z], "Etc/UTC")}
# `~U[2018-01-01T15:24:00Z]` in Elixir 1.9+

iex> DateTimeParser.parse_datetime(~s|"Mar 28, 2018 7:39:53 AM PDT"|, to_utc: true)
{:ok, DateTime.from_naive!(~N[2018-03-28T14:39:53Z], "Etc/UTC")}

iex> {:ok, datetime} = DateTimeParser.parse_datetime(~s|"Mar 1, 2018 7:39:53 AM PST"|)
iex> datetime
#DateTime<2018-03-01 07:39:53-08:00 PST PST8PDT>

iex> DateTimeParser.parse_datetime(~s|"Mar 1, 2018 7:39:53 AM PST"|, to_utc: true)
{:ok, DateTime.from_naive!(~N[2018-03-01T15:39:53Z], "Etc/UTC")}

iex> {:ok, datetime} = DateTimeParser.parse_datetime(~s|"Mar 28, 2018 7:39:53 AM PDT"|)
iex> datetime
#DateTime<2018-03-28 07:39:53-07:00 PDT PST8PDT>

iex> DateTimeParser.parse_time("10:13pm")
{:ok, ~T[22:13:00]}

iex> DateTimeParser.parse_time("10:13:34")
{:ok, ~T[10:13:34]}

iex> DateTimeParser.parse_time("18:14:21.145851000000Z")
{:ok, ~T[18:14:21.145851]}

iex> DateTimeParser.parse_datetime(nil)
{:error, "Could not parse nil"}
```

## Installation

Add `date_time_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:date_time_parser, "~> 1.1.5"}
  ]
end
```

## Configuration

```elixir
# This is the default config
alias DateTimeParser.Parser
config :date_time_parser, parsers: [Parser.Epoch, Parser.Serial, Parser.Tokenizer]

# To enable only specific parsers, include them in the :parsers key.
config :date_time_parser, parsers: [Parser.Tokenizer]

# Or in runtime, pass in the parsers in the function.
DateTimeParser.parse(mystring, parsers: [Parser.Tokenizer])
```

## Write your own parser

You can write your own parser!

If the built-in parsers are not applicable for your use-case, you may build your
own parser to use with this library. Let's write a simple one together.

First I will check `DateTimeParser.Parser` to see what behaviour my new parser
should implement. It needs two functions:

1. `c:DateTimeParser.Parser.preflight/1`
1. `c:DateTimeParser.Parser.parse/1`

These functions accept the `t:DateTimeParser.Parser.t/0` struct which contains the
options supplied by the user, the string itself, and the context for which you
should return your result. For example, if the context is `:time` then you should
return a `%Time{}`; if `:datetime` you should return either a
`%NaiveDateTime{}` or a `%DateTime{}`; if `:date` then you should return a
`%Date{}`.

Let's implement a parser that reads a special time string. Our string will
represent time, but all the digits are shifted up by 10 and must be prefixed
with the secret word: `"boomshakalaka:"`. For example, the real world time of
`01:10` is represented as `boomshakalaka:11:20` in our toy time format. `12:30`
is represented as `boomshakalaka:22:40`, and `5:55` is represented as
`boomshakalaka:15:65`.

```elixir
defmodule MyParser do
  @behaviour DateTimeParser.Parser
  @secret_regex ~r|boomshakalaka:(?<time>\d{2}:\d{2})|

  def preflight(%{string: string} = parser) do
    case Regex.named_captures(@secret_regex, string) do
      %{"time" => time} ->
        {:ok, %{parser | preflight: time}}

      nil ->
        {:error, :not_compatible}
    end
  end

  # ... more below
end
```

We'll stop here first and go through the preflight function. Our special parser
will only be attempted if the supplied string has any named captures from the
regex. That is, it must begin with `bookshakalaka:` followed by 2 digits, a
colon, and 2 more digits. These digits are extracted out like `00:00` where 0 is
any digit. If `05:40` is passed in, it would not be compatible so the parser
will be skipped.

Now let's parse the time:

```elixir
def parse(%{preflight: time} = parser) do
  [hour, minute] = String.split(time, ":")
  {hour, ""} = Integer.parse(hour)
  {minute, ""} = Integer.parse(minute)
  result = Time.new(hour - 10, minute - 10, 0, {0, 0})
  for_context(parser.context, result)
end

defp for_context(:datetime, _result), do: :error
defp for_context(:date, _result), do: :error
defp for_context(:time, result), do: result
```

Notice that we need to consider context of the result. If the user asked for a
DateTime, then we need to give them one. In our toy format, it only represents
time, so therefore we must return an error when the context is a `:datetime` or
`:date`.

```elixir
DateTimeParser.parse_time("boomshakalaka:11:11", parsers: [MyParser])
#=> {:ok, ~T[01:01:00]}

DateTimeParser.parse_date("boomshakalaka:11:11", parsers: [MyParser])
#=> {:error, "Could not parse \"boomshakalaka:11:11\""}

DateTimeParser.parse_datetime("boomshakalaka:11:11", parsers: [MyParser])
#=> {:error, "Could not parse \"boomshakalaka:11:11\""}

DateTimeParser.parse("boomshakalaka:11:11", parsers: [MyParser])
#=> {:ok, ~T[01:01:00]}

```

## Should I use this library?

Only as a last resort. Parsing dates from strings is educated guessing at best.
Since Elixir natively supports [ISO-8601] parsing (see `from_iso8601/2`
functions), it's highly recommended that you rely on that first and foremost.

When designing your API that involves dates and strings, be specific with your
requirements and supported DateTime strings, and preferably only support
[ISO-8601] with no exceptions. There is _no_ ambiguity with this format so
parsing to DateTime (or Date or Time) will always be correct.

This library is helpful when you _must_ accept ambiguous DateTime string formats
and having incorrect results is acceptable. Do not use this library when the
resulting (and possibly incorrect) DateTime has catastrophic and dangerous
effects in your system.

[ISO-8601]: https://en.wikipedia.org/wiki/ISO_8601

<!-- MDOC -->

## How to store future timestamps

[see guide](./pages/Future-UTC-DateTime.md)

tldr: rules change, so don't convert to UTC too early. The future might change
the timezone conversion rules.

## Changelog

[View Changelog](./CHANGELOG.md)

## Upgrading from 0.x to 1.0

* If you use `parse_datetime/1`, then change to `parse_datetime/2` with the
  second argument as a keyword list to `assume_time: true` and `to_utc: true`.
  In 0.x, it would merge `~T[00:00:00]` if the time tokens could not be parsed;
  in 1.x, you have to opt into this behavior. Also in 0.x, a non-UTC timezone
  would automatically convert to UTC; in 1.x, the original timezone will be
  kept instead.
* If you use `parse_date/1`, then change to `parse_date/2` with the second
  argument as a keyword list to `assume_date: true`. In 0.x, it would merge
  `Date.utc_today()` with the found date tokens; in 1.x, you need to opt into
  this behavior.
* If you use `parse_time`, there is no breaking change but parsing has been
  improved.
* Not a breaking change, but 1.x introduces `parse/2` that will return the best
  struct from the tokens. This may influence your usage.

## Contributing

[How to contribute](./CONTRIBUTING.md)

## Special Thanks

[<img src="https://github.com/taxjar/date_time_parser/blob/master/images/taxjar_sponsor.jpg?raw=true" alt="TaxJar" height=75 />](https://www.taxjar.com)
