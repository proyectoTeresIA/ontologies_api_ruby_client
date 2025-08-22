require_relative "../base"

module LinkedData
  module Client
    module Models
      class Project < LinkedData::Client::Base
        include LinkedData::Client::Collection
        include LinkedData::Client::ReadWrite

        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Project')
        end
      end
    end
  end
end
