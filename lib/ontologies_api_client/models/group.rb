require_relative "../base"

module LinkedData
  module Client
    module Models
      class Group < LinkedData::Client::Base
        include LinkedData::Client::Collection
        
        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Group')
        end
      end
    end
  end
end
