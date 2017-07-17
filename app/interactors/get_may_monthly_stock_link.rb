require 'nokogiri'
require 'open-uri'

class GetMayMonthlyStockLink < SireneAsAPIInteractor
  around do |interactor|
    stdout_info_log "Visiting may stock distant directory"
    interactor.call
    stdout_success_log "Retrieved may monthly stock link : #{context.link}"
    puts
  end

  def call
    last_monthly_stock_relative_link = "sirene_201705_L_M.zip"
    context.link = "http://files.data.gouv.fr/sirene/sirene_201705_L_M.zip"
  end

  private
  def stock_relative_links
    sirene_update_and_stock_links.select do |l|
      l[:href].match(sirene_monthly_stock_filename_pattern)
    end
  end

  def files_domain
    'http://files.data.gouv.fr'
  end

  def files_repository
    "#{files_domain}/sirene"
  end

  def sirene_monthly_stock_filename_pattern
    /.*sirene_#{current_year}([0-9]{2})_L_M\.zip/
  end

  def current_year
    Time.now.year.to_s
  end
end
