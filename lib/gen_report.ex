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
