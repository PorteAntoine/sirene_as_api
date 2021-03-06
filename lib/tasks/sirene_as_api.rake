namespace :sirene_as_api do
  desc 'Populate db with last monthly stock'
  task import_last_monthly_stock: :environment do
    ImportLastMonthlyStock.call
  end

  desc 'Updates database (manual mode)'
  task update_database: :environment do
    UpdateDatabase.call
  end

  desc 'Updates database (automatically accept user prompts and delete tmp files)'
  task automatic_update_database: :environment do
    AutomaticUpdateDatabase.call
  end

  desc 'Populate database with stock and apply relevant patches'
  task populate_database: :environment do
    PopulateDatabase.call
  end

  desc 'Delete all rows in database'
  task delete_database: :environment do
    DeleteDatabase.call
  end

  desc 'Delete temporary files (monthly stock and daily patches)'
  task delete_temporary_files: :environment do
    DeleteTemporaryFiles.call
  end
end
