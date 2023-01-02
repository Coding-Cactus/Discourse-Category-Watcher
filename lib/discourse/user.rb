module Discourse
    class User
        attr_reader :name, :url, :pfp
        
        def initialize(id, topic_users, base_url)
            user = topic_users.select { |u| u["id"] == id }[0]

            @name = user["username"]
            @url  = "#{base_url}/u/#{@name}"
            
            @pfp = user["avatar_template"].sub("{size}", "120")
            @pfp = base_url + @pfp if @pfp[0] == "/"
        end
    end
end
