require_relative "../base"

module LinkedData
  module Client
    module Models
      class Property < LinkedData::Client::Base
        # Set media_type dynamically based on configuration
        def self.media_type
          @media_type ||= LinkedData::Client.metadata_url('metadata/Property')
        end
        
        @act_as_media_type = ["http://www.w3.org/2002/07/owl#DatatypeProperty", "http://www.w3.org/2002/07/owl#ObjectProperty", "http://www.w3.org/2002/07/owl#AnnotationProperty"]
        @include_attrs = "all"

        def self.properties_to_hash(ary)
          ary = ary.is_a?(Array) ? ary : [ary]
          ary.map {|p| p.to_hash}
        end

        def prefLabel(options = {})
          return "" if @label.nil? && @id.nil?
          label = @label.first || id_to_label
          if options[:use_html]
            return "<span class='prefLabel'>#{label}</span>"
          else
            return label
          end
        end

        def id_to_label
          @id.split("/").last.split("#").last
        end

        def childrenCount
          (@children ||= []).length
        end

        def children
          (@children ||= [])
        end

        def expanded?
          self.childrenCount > 0
        end

        def to_hash
          hash = super
          hash[:prefLabel] = self.prefLabel
          hash[:childrenCount] = self.childrenCount
          if children.length > 0
            hash[:children] = self.children.map {|p| p.to_hash}
          end
          hash
        end

        def ontology
          # hack to get ontology, split the submission URI and trust the path hasn't changed
          acronym = @submission.split("/")[4]
          LinkedData::Client::Models::Ontology.find_by_acronym(acronym).first
        end

      end
    end
  end
end