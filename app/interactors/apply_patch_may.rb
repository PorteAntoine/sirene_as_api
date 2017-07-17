class ApplyPatchMay
  include Interactor::Organizer

  organize DownloadFile, UnzipFile, ApplyFrequentUpdateCsvPatchMay
end
