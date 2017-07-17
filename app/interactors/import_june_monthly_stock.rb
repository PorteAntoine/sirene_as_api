class ImportJuneMonthlyStock
  include Interactor::Organizer

  organize GetJuneMonthlyStockLink, DownloadFile, UnzipFile, ImportMonthlyStockCsvJune
end
