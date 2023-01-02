require "htmlentities"

module Discourse
    class Topic
        attr_reader :id, :slug, :url, :title, :author
        
        def initialize(data, users, base_url)            
            @id   = data["id"]
            @slug = data["slug"]
            @url  = "#{base_url}/t/#{@slug}/#{@id}"
            
            @title  = data["title"]
            @author = User.new(data["posters"][0]["user_id"], users, base_url)       
        end

        def description
            raw(JSON.parse(HTTP.get("#{@url}.json"))["post_stream"]["posts"][0]["cooked"])
        end

        private

        def raw(description)
            # emojis
            d = description.clone
            description.scan(/(<img[^>]*alt=\"([^\"]*)\"[^>]*>)/) { |tag, emoji| d.sub!(tag, emoji) if emoji.include?(":") }

            # links
            description = d.clone            
            description.scan(/(<a[^>]*href=\"([^\"]*)\"[^>]*>([^<]*)<\/a>)/) { |tag, url, text| d.sub!(tag, "[#{text}](#{url})") }

            # remove rest of tags + decode html encoded chars
            HTMLEntities.new.decode(d.gsub(/<\/?pre[^>]*>/, "```").gsub(/<[^>]*>/, ""))
        end
    end
end
