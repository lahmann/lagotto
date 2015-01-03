# Networking constants
DEFAULT_TIMEOUT = 60
NETWORKABLE_EXCEPTIONS = [Faraday::Error::ClientError,
                          Delayed::WorkerTimeout,
                          URI::InvalidURIError,
                          Encoding::UndefinedConversionError,
                          ArgumentError,
                          NoMethodError,
                          TypeError]

# Format used for DOI validation
# The prefix is 10.x where x is 4-5 digits. The suffix can be anything, but can't be left off
DOI_FORMAT = %r(\A10\.\d{4,5}/.+)

# Format used for URL validation
URL_FORMAT = %r(\A(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z)

# Form interval options
INTERVAL_OPTIONS = [['½ hour', 30.minutes],
                    ['1 hour', 1.hour],
                    ['2 hours', 2.hours],
                    ['3 hours', 3.hours],
                    ['6 hours', 6.hours],
                    ['8 hours', 8.hours],
                    ['12 hours', 12.hours],
                    ['24 hours', 24.hours],
                    ['2 days', 48.hours],
                    ['4 days', 96.hours],
                    ['¼ month', (1.month * 0.25).to_i],
                    ['½ month', (1.month * 0.5).to_i],
                    ['1 month', 1.month],
                    ['3 months', 3.months],
                    ['6 months', 6.months],
                    ['12 months', 12.months]]

# CrossRef types from http://api.crossref.org/types
CROSSREF_TYPE_TRANSLATIONS = {
  "proceedings" => nil,
  "reference-book" => nil,
  "journal-issue" => nil,
  "proceedings-article" => "paper-conference",
  "other" => nil,
  "dissertation" => "thesis",
  "dataset" => "dataset",
  "edited-book" => "book",
  "journal-article" => "article-journal",
  "journal" => nil,
  "report" => "report",
  "book-series" => nil,
  "report-series" => nil,
  "book-track" => nil,
  "standard" => nil,
  "book-section" => "chapter",
  "book-part" => nil,
  "book" => "book",
  "book-chapter" => "chapter",
  "standard-series" => nil,
  "monograph" => "book",
  "component" => nil,
  "reference-entry" => "entry-dictionary",
  "journal-volume" => nil,
  "book-set" => nil
}

# DataCite resourceTypeGeneral from DataCite metadata schema: http://dx.doi.org/10.5438/0010
DATACITE_TYPE_TRANSLATIONS = {
  "Audiovisual" => "motion_picture",
  "Collection" => nil,
  "Dataset" => "dataset",
  "Event" => nil,
  "Image" => "graphic",
  "InteractiveResource" => nil,
  "Model" => nil,
  "PhysicalObject" => nil,
  "Service" => nil,
  "Software" => nil,
  "Sound" => "song",
  "Text" => "report",
  "Workflow" => nil,
  "Other" => nil
}
