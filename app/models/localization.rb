class Localization < ActiveRecord::Base
  belongs_to :blurb
  belongs_to :locale
  belongs_to :published_version, :class_name => 'Version'
  has_many :versions

  validates_presence_of :blurb_id, :locale_id

  after_create :create_first_version

  def alternates
    blurb.localizations.joins(:locale).where(:locales => { :enabled => true }).
      order('locales.%s' % connection.quote_column_name('key'))
  end

  def as_json(options = nil)
    super :only => [:id, :draft_content], :methods => [:key]
  end

  def key
    blurb.key
  end

  def key_with_locale
    [locale.key, blurb.key].join '.'
  end

  def self.in_locale(locale)
    where :locale_id => locale.id
  end

  def self.in_locale_with_blurb(locale)
    includes(:blurb).in_locale(locale).ordered
  end

  def latest_version
    versions.last
  end

  def self.latest_version
    <<-eosql
      SELECT DISTINCT (localization_id) localization_id, id, content
        FROM versions ORDER BY localization_id DESC, id DESC
    eosql
  end

  def next_version_number
    versions.count + 1
  end

  def self.ordered
    joins(:blurb).order('blurbs.%s' % connection.quote_column_name('key'))
  end

  def self.publish
    sql = <<-SQL
      UPDATE localizations localizations,
        (#{latest_version}) as latest_version
      SET published_version_id = latest_version.id,
      published_content = latest_version.content,
      updated_at = '#{connection.quoted_date(Time.now)}'
      WHERE latest_version.localization_id = localizations.id
    SQL
    if scoped.present?
      sql += <<-SQL
        AND localizations.id IN (#{scoped.map(&:id).join(',')});
      SQL
    end
    ActiveRecord::Base.connection.execute sql
  end

  def publish
    self.class.where(:id => self.id).publish
    reload
  end

  def project
    blurb.project
  end

  def revise(attributes = {})
    latest_version.revise attributes
  end

  private

  def create_first_version
    versions.build(:content => draft_content).tap do |version|
      version.number = 1
      version.save!
    end
  end
end
