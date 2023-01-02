module Discourse
    class Client
        def initialize(domain)
            @base_url = "https://#{domain}"
        end

        def get_category(id)
            Category::new(JSON.parse(HTTP.get("#{@base_url}/c/#{id}/show.json"))["category"], @base_url)
        end
    end
end
