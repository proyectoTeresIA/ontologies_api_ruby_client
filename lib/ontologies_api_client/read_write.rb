require 'active_support/core_ext/hash'

module LinkedData
  module Client
    module ReadWrite
      HTTP = LinkedData::Client::HTTP

      def save(options = {})
        resp = HTTP.post(self.class.collection_path, self.to_hash)
        cache_refresh(options)
        resp
      end

      def update(options = {})
        values = options[:values] || changed_values()
        return if values.empty?
        resp = HTTP.patch(self.id, values)
        cache_refresh(options)
        resp
      end

      def update_from_params(params)
        # We want to populate ALL the attributes from the REST
        # service so we know that what we're updating is
        # actually the full object
        all_values = HTTP.get(self.id, include: "all")
        all_values.instance_variables.each do |var|
          self.send("#{var}=", all_values.instance_variable_get(var))
        end

        # Now we override the retrieved attributes with new ones
        params.each do |k,v|
          self.send("#{k}=", v) rescue next
        end
        self
      end

      def changed_values
        existing = HTTP.get(self.id, include: 'all')
        changed_attrs = {}
        self.instance_variables.each do |var|
          var_sym = var[1..-1].to_sym
          next if [:id, :type, :links, :context, :created].include?(var_sym)
          new_value = self.instance_variable_get(var)
          current_value = existing.instance_variable_get(var)
          changed_attrs[var_sym] = new_value unless equivalent?(current_value, new_value)
        end
        changed_attrs
      end

      def delete(invalidate_cache = true)
        delete_url = self.class.id_to_rest_url(@id) if @id
        if invalidate_cache
          cache_refresh
        end
        LinkedData::Client::HTTP.delete(delete_url, self.class.media_type)
      end

      private

      def cache_refresh(options = {})
        invalidate_cache()
      end

      def equivalent?(current_value, new_value)
        # If we're comparing an existing embedded object
        # then use the id for comparison
        if current_value.is_a?(LinkedData::Client::Base)
          return current_value.id.eql?(new_value)
        end

        # Otherwise, do some complex comparing
        case new_value
        when String
          return current_value.to_s.eql?(new_value)
        when Array, Hash
          new_value = nil if new_value.is_a?(Array) && new_value.empty? && current_value.nil?
          if new_value.is_a?(Array) && new_value.first.is_a?(Hash)
            clean_current = current_value.map {|e| e.to_h.symbolize_keys.delete_if {|k,v| v.nil?}}.sort_by {|e| e.is_a?(Hash) ? e.values.sort : e}
            clean_new = new_value.map {|e| e.symbolize_keys.delete_if {|k,v| v.nil?}}.sort_by {|e| e.is_a?(Hash) ? e.values.sort : e}
            return clean_current.eql?(clean_new) rescue clean_current == clean_new
          else
            return current_value.sort.eql?(new_value.sort) rescue current_value == new_value
          end
        end
        return current_value.eql?(new_value) rescue current_value == new_value
      end

      def invalidate_cache
        url = self.class.id_to_rest_url(@id) if @id
        return unless url
        
        begin
          LinkedData::Client::HTTP.get(url)
        rescue Exception => e
          puts "Warning: Could not invalidate cache for #{url}: #{e.message}" if LinkedData::Client.settings.debug_client
        end
      end
    end
  end
end
