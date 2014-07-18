module Camelizable
  refine String do
    def camelize
      dup.gsub(/(?:^|[_ -])([a-z])/) { $1.upcase }.gsub(/\s/, '')
    end
  end
end
