require_relative "../base"

module LinkedData
  module Client
    module Models
      class Metrics < LinkedData::Client::Base
        include LinkedData::Client::Collection

        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Metrics')
        end
      end
    end
  end
end
