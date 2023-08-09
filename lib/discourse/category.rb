module Discourse
    class Category
        attr_reader :name, :colour

        def initialize(data, base_url)
            @id       = data["id"]
            @slug     = data["slug"]
            @name     = data["name"]
            @users    = data["users"]
            @colour   = data["color"].to_i(16)
            @base_url = base_url
        end

        def get_topics
            data = JSON.parse(HTTP.follow.get("#{@base_url}/c/#{@slug}/#{@id}.json"))

            raise "Category of id #{@id} does not exist" if data["error_type"] == "not_found"

            data["topic_list"]["topics"].map { |t| Topic.new(t, data["users"], @base_url) }
        end
    end
end
