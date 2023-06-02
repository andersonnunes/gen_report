defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "freelas.csv"
  @filenames ["freela_1.csv", "freela_2.csv", "freela_3.csv"]

  describe "build/1" do
    test "when passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "when no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "when a file list is provided, builds the report" do
      response = GenReport.build_from_many(@filenames)

      assert response == {:ok, ReportFixture.build()}
    end

    test "when a file list is not provided, returns an error" do
      response = GenReport.build_from_many(@file_name)

      assert response == {:error, "Insira uma lista com nomes de arquivo"}
    end
  end
end
