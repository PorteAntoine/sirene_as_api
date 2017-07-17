# This script is not for human eyes. Please don't look at it.
require 'logger'

class CompareDatabases < SireneAsAPIInteractor

  def call
    mylog = Logger.new('log/comparison_database.txt')
    return false unless compare_both_sirets
    all_sirets = compare_and_get_siret_array
    stdout_info_log("Starting comparison...")

    progress_bar = ProgressBar.create(
      total: all_sirets.size,
      format: 'Progress %c/%C |%b>%i| %a %e'
    )
    quietly do
      all_sirets.each do |siret|
        compare_rows(siret, mylog)
        progress_bar.increment
      end
    end

    if (@are_databases_identical === false)
      stdout_warn_log("A difference was found. Check log file for details")
    elsif ()
      stdout_success_log("SUCCESS ! Both databases identical !")
    end
  end

  def compare_both_sirets
    stdout_info_log("Comparing first SIRET on both databases...")
    if (EtablissementMayToJune.first_siret_database === EtablissementJune.first_siret_database)
      stdout_success_log("Same SIRET : #{EtablissementMayToJune.first_siret_database}. Continuing...")
    else
      stdout_warn_log("NOT same SIRET. Siret may to june : #{EtablissementMayToJune.first_siret_database},
        Siret june: #{EtablissementJune.first_siret_database}")
      return false
    end
    stdout_info_log("Comparing last SIRET on both databases...")
    if (EtablissementMayToJune.last_siret_database === EtablissementJune.last_siret_database)
      stdout_success_log("Same SIRET : #{EtablissementMayToJune.last_siret_database}. Continuing...")
    else
      stdout_warn_log("NOT same SIRET. Siret may to june : #{EtablissementMayToJune.first_siret_database},
        Siret june: #{EtablissementJune.last_siret_database}")
      return false
    end
    return true
  end

  def compare_and_get_siret_array
    stdout_info_log("Extracting sirets...")
    siret_array_first_database = EtablissementMayToJune.pluck(:siret)
    siret_array_second_database = EtablissementJune.pluck(:siret)
    # stdout_info_log("Extracted sirets. sorting arrays...")
    # siret_array_first_database.sort!
    # siret_array_second_database.sort!
    stdout_info_log("Sorted arrays. Comparing...")
    length_maytojune = siret_array_first_database.length
    length_june = siret_array_second_database.length
    stdout_info_log("Length array MayToJune: #{length_maytojune}")
    stdout_info_log("Length array June: #{length_june}")
    if (siret_array_first_database.length === siret_array_second_database.length)
      stdout_success_log("Both tables have same size")
    else
      stdout_warn_log("Warning : Both tables don't have same size. Databases are differents. Check log file for details.")
    end
    if (length_maytojune > length_june)
      return siret_array_first_database
    else
      return siret_array_second_database
    end
  end

  def compare_rows(siret, mylog)
    etablissement_first_database = EtablissementMayToJune.where(siret: siret).first
    etablissement_second_database = EtablissementJune.where(siret: siret).first
    if (etablissement_first_database == nil && etablissement_second_database != nil)
      mylog.info("Difference found : MaytoJune exist but June doesn't for siret : #{siret}")
    elsif (etablissement_first_database != nil && etablissement_second_database == nil)
      mylog.info("Difference found : June exist but MayToJune doesn't for siret : #{siret}")
    elsif (etablissement_first_database == nil && etablissement_second_database == nil)
      mylog.info("A siret with no name in both databases was found : #{siret}")
    elsif (etablissement_first_database.nom_raison_sociale != etablissement_second_database.nom_raison_sociale)
      # stdout_info_log("Difference found : MaytoJune: #{etablissement_first_database.siret} Value : #{etablissement_first_database.nom_raison_sociale} \n
      #   June: #{etablissement_second_database.siret} Value : #{etablissement_second_database.nom_raison_sociale}")
      mylog.info("Difference found : MaytoJune: #{etablissement_first_database.siret} Value : #{etablissement_first_database.nom_raison_sociale}
        June: #{etablissement_second_database.siret} Value : #{etablissement_second_database.nom_raison_sociale}")
    end
  end

  def quietly
    ar_log_level_before_block_execution = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = :fatal

    log_level_before_block_execution = Rails.logger.level

    yield

    Rails.logger.level = log_level_before_block_execution

    ActiveRecord::Base.logger.level = ar_log_level_before_block_execution
  end
end
