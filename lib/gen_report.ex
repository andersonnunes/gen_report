defmodule GenReport do
  alias GenReport.Parser

  @all_users [
    "daniele",
    "mayk",
    "giuliano",
    "cleiton",
    "jakeliny",
    "joseph",
    "diego",
    "danilo",
    "rafael",
    "vinicius"
  ]

  @all_months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.map(fn line -> line end)
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Insira uma lista com nomes de arquivo"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp sum_values([name, qt_hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + qt_hours)

    hours_per_month =
      put_in(hours_per_month, [name, month], hours_per_month[name][month] + qt_hours)

    hours_per_year = put_in(hours_per_year, [name, year], hours_per_year[name][year] + qt_hours)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps_nested(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps_nested(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_maps_nested(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps(value1, value2) end)
  end

  defp report_acc do
    all_hours = Enum.into(@all_users, %{}, &{&1, 0})
    all_months = Enum.into(@all_months, %{}, &{&1, 0})
    all_years = Enum.into(2016..2020, %{}, &{&1, 0})
    hours_per_month = Enum.into(@all_users, %{}, &{&1, all_months})
    hours_per_year = Enum.into(@all_users, %{}, &{&1, all_years})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
