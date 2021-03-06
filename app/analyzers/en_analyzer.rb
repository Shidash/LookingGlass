module ENAnalyzer
  extend MultiDataset
  
  def self.analyzerSettings
    # Current LIMITATION: Takes synonym list from first dataspec- maybe pass in dataspec instead?
    
    # Load dataspecs but don't load all- that ends in an infinite loop
    @instance = InstanceSpec.new
    loadAllDatasets

    # Settings
    return {
      index: {
        number_of_shards: 1,
        analysis: {
          filter: {
            english_stop: {
              type: 'stop',
              stopwords: '_english_'
            },
            english_stemmer: {
              type: 'stemmer',
              language: 'english'
            },
            english_possessive_stemmer: {
              type: 'stemmer',
              language: 'possessive_english'
            },
            synonyms: {
              type: 'synonym',
              synonyms: File.read(@dataspecs[0].synonym_list).split("\n")
            }
          },       
          analyzer: {
            custom_en_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            filter: [
                     "english_possessive_stemmer",
                     "lowercase",
                     "synonyms",
                     "english_stop",
                     "english_stemmer",
                     "asciifolding"
                    ]
            },
          },
        },
      },
    }.freeze
  end
end
