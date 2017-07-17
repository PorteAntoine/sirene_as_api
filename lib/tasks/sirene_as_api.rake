namespace :sirene_as_api do
  desc 'Populate db with last monthly stock'
  task :import_last_monthly_stock => :environment do
    ImportLastMonthlyStock.call
  end

  desc 'Updates database'
  task :select_and_apply_patches => :environment do
    SelectAndApplyPatches.call
  end

  desc 'Populate database with stock and apply relevant patches'
  task :populate_database => :environment do
    PopulateDatabase.call
  end


## Delete following tasks after tests
  desc 'Import june stock in database'
  task :import_june_monthly_stock => :environment do
    ImportJuneMonthlyStock.call
  end

  desc 'Import may stock in database'
  task :import_may_monthly_stock => :environment do
    ImportMayMonthlyStock.call
  end

  desc 'Updates database for may to june'
  task :select_and_apply_patches_may => :environment do
    SelectAndApplyPatchesMay.call
  end

  desc 'Compare databases'
  task :Compare_databases => :environment do
    CompareDatabases.call
  end
end
