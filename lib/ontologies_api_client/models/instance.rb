require_relative "../base"

module LinkedData
  module Client
    module Models
      class Instance < LinkedData::Client::Base
        include LinkedData::Client::Collection
        
        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Instance')
        end
      end
    end
  end
end
