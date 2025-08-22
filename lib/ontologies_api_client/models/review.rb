require_relative "../base"

module LinkedData
  module Client
    module Models
      class Review < LinkedData::Client::Base
        include LinkedData::Client::Collection
        include LinkedData::Client::ReadWrite

        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Review')
        end
      end
    end
  end
end
