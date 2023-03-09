defmodule DateTimeParser.TimezoneParserTest do
  use ExUnit.Case, async: true

  alias DateTimeParser.TimezoneParser

  describe "parsing zones" do
    test "parses a zone" do
      sample = """
      Zone America/New_York	-4:56:02 -	LMT	1883 Nov 18 17:00u
      			-5:00	US	E%sT	1920
      			-5:00	NYC	E%sT	1942
      			-5:00	US	E%sT	1946
      			-5:00	NYC	E%sT	1967
      			-5:00	US	E%sT
      """

      {[zone1, zone2, zone3, zone4, zone5, zone6] = zones, []} = TimezoneParser.parse(sample)
      assert Enum.all?(zones, &(&1.name == "America/New_York"))
      assert zone1.utc_offset_sec == -17_762
      assert zone1.utc_offset_hrs == "-0456"
      assert zone1.abbreviations == ["LMT"]
      assert zone1.from == nil
      assert zone1.until == ~U[1883-11-18 17:00:00Z]

      assert Enum.all?([zone2, zone3, zone4, zone5, zone6], &(&1.utc_offset_sec == -18_000))
      assert Enum.all?([zone2, zone3, zone4, zone5, zone6], &(&1.utc_offset_hrs == "-0500"))
      assert Enum.all?([zone2, zone3, zone4, zone5, zone6], &(&1.abbreviations == []))
      assert zone2.from == ~U[1883-11-18 17:00:00Z]
      assert zone2.until == ~N[1920-01-01 00:00:00]
      assert zone3.from == ~N[1920-01-01 00:00:00]
      assert zone3.until == ~N[1942-01-01 00:00:00]
      assert zone4.from == ~N[1942-01-01 00:00:00]
      assert zone4.until == ~N[1946-01-01 00:00:00]
      assert zone5.from == ~N[1946-01-01 00:00:00]
      assert zone5.until == ~N[1967-01-01 00:00:00]
      assert zone6.from == ~N[1967-01-01 00:00:00]
      refute zone6.until
    end

    test "parses rules" do
      sample = """
      Rule	US	1918	1919	-	Mar	lastSun	2:00	1:00	D
      Rule	US	1918	1919	-	Oct	lastSun	2:00	0	S
      Rule	US	1942	only	-	Feb	9	2:00	1:00	W # War
      Rule	US	1945	only	-	Aug	14	23:00u	1:00	P # Peace
      Rule	US	1945	only	-	Sep	30	2:00	0	S
      Rule	US	1967	2006	-	Oct	lastSun	2:00	0	S
      Rule	US	1967	1973	-	Apr	lastSun	2:00	1:00	D
      Rule	US	1974	only	-	Jan	6	2:00	1:00	D
      Rule	US	1975	only	-	Feb	lastSun	2:00	1:00	D
      Rule	US	1976	1986	-	Apr	lastSun	2:00	1:00	D
      Rule	US	1987	2006	-	Apr	Sun>=1	2:00	1:00	D
      Rule	US	2007	max	-	Mar	Sun>=8	2:00	1:00	D
      Rule	US	2007	max	-	Nov	Sun>=1	2:00	0	S
      Rule	NYC	1920	only	-	Mar	lastSun	2:00	1:00	D
      Rule	NYC	1920	only	-	Oct	lastSun	2:00	0	S
      Rule	NYC	1921	1966	-	Apr	lastSun	2:00	1:00	D
      Rule	NYC	1921	1954	-	Sep	lastSun	2:00	0	S
      Rule	NYC	1955	1966	-	Oct	lastSun	2:00	0	S
      """

      {[], [rule1, rule2, rule3 | _rest]} = TimezoneParser.parse(sample)

      # Rule	NYC	1920	only	-	Mar	lastSun	2:00	1:00	D
      assert rule1.name == "NYC"
      assert rule1.from == ~N[1920-03-28 02:00:00]
      assert rule1.until == ~N[1920-03-28 02:00:00]
      assert rule1.save == 3600
      assert rule1.letter == "D"

      # Rule	NYC	1920	only	-	Oct	lastSun	2:00	0	S
      assert rule2.name == "NYC"
      assert rule2.from == ~N[1920-10-31 02:00:00]
      assert rule2.until == ~N[1920-10-31 02:00:00]
      assert rule2.save == 0
      assert rule2.letter == "S"

      # Rule	NYC	1921	1966	-	Apr	lastSun	2:00	1:00	D
      assert rule3.name == "NYC"
      assert rule3.from == ~N[1921-04-24 02:00:00]
      assert rule3.until == ~N[1966-04-24 02:00:00]
      assert rule3.save == 3600
      assert rule3.letter == "D"
    end
  end
end
