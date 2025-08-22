require_relative "../base"

module LinkedData
  module Client
    module Models
      class Note < LinkedData::Client::Base
        include LinkedData::Client::Collection
        include LinkedData::Client::ReadWrite
        
        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Note')
        end

        def deletable?(user)
          false
        end

        def uuid
          self.id.split("/").last
        end
      end
    end
  end
end
