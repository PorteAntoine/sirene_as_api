class ImportMonthlyStockCsv < SireneAsAPIInteractor
  around do |interactor|
    stdout_info_log 'Starting csv import'
    stdout_info_log 'Computing number of rows'

    context.csv_filename = context.unzipped_files.first
    context.number_of_rows = `wc -l #{context.csv_filename}`.split.first.to_i - 1

    stdout_success_log "Found #{context.number_of_rows} rows to import"

    stdout_info_log 'Importing rows'

    quietly do
      stdout_etablissement_count_change do
        stdout_benchmark_stats do
          interactor.call
        end
      end
    end

    puts
  end

  def call
    unless clean_database?
      stdout_warn_log("Database not empty.
        Please run 'bundle exec rake sirene_as_api:delete_database' before populating.")
      context.fail!(error: 'database should be empty before importing a stock file')
      return
    end

    progress_bar = create_progressbar(context)

    process_csv_job(context, progress_bar)
  end

  def clean_database?
    Etablissement.first.nil?
  end

  def create_progressbar(context)
    ProgressBar.create(
      total: context.number_of_rows,
      format: 'Progress %c/%C (%P %%) |%b>%i| %a %e'
    )
  end

  def process_csv_job(context, progress_bar)
    SmarterCSV.process(context.csv_filename, csv_options) do |chunk|
      InsertEtablissementRowsJob.new(chunk).perform
      chunk.size.times { progress_bar.increment }
    end
  end

  def csv_options
    {
      chunk_size: 10_000,
      col_sep: ';',
      row_sep: "\r\n",
      convert_values_to_numeric: false,
      key_mapping: {},
      file_encoding: 'windows-1252'
    }
  end

  def quietly
    ar_log_level_before_block_execution = ActiveRecord::Base.logger.level
    log_level_before_block_execution = Rails.logger.level

    Rails.logger.level = :fatal
    ActiveRecord::Base.logger.level = :error
    yield
    Rails.logger.level = log_level_before_block_execution
    ActiveRecord::Base.logger.level = ar_log_level_before_block_execution
  end

  def stdout_etablissement_count_change
    etablissement_count_before = Etablissement.count
    yield
    etablissement_count_after = Etablissement.count

    entries_added = etablissement_count_after - etablissement_count_before

    puts "#{entries_added} etablissements added"
  end

  def stdout_benchmark_stats
    Benchmark.bm(7) do |x|
      x.report(:csv_pro) do
        yield
      end
    end
  end
end
