# Upgrading from 0.x to 1.0

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
