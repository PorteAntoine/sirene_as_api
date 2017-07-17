class ImportMayMonthlyStock
  include Interactor::Organizer

  organize GetMayMonthlyStockLink, DownloadFile, UnzipFile, ImportMonthlyStockCsvMayToJune
end
