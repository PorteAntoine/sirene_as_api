# Class Etablissement

class EtablissementJune < ApplicationRecord
  attr_accessor :csv_path
  # default_scope -> { where.not(nature_mise_a_jour: ["E", "O"]) }

  searchable do
    text :nom_raison_sociale
    string :activite_principale
    string :code_postal
  end

  def self.latest_mise_a_jour
    latest_entry.try(:date_mise_a_jour)
  end

  def self.latest_entry
    unscoped.limit(1).order('date_mise_a_jour DESC').first
  end

  def self.first_siret_database
    unscoped.order('siret DESC').last.siret
  end

  def self.last_siret_database
    unscoped.limit(1).order('siret DESC').first.siret
  end
end
