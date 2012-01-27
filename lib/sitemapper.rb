require "builder"
require "open-uri"

module SiteMapper
   module ClassMethods
      def write_sitemap(sitemap,method,extras=nil,extra_meth=nil)
         xml         = Builder::XmlMarkup.new(:indent=>2)
         change      = sitemapper[:changefreq]
         priority    = sitemapper[:priority]
         extra_meth  = extra_meth ? extra_meth : method
         col         = send(method)
         col         = col + extras.send(extra_meth) if extras
         xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
            col.each do |value|
               xml.url do
                  xml.loc        value[sitemapper[:loc]]
                  xml.lastmod    value[sitemapper[:lastmod]]
                  xml.changefreq value[change]   ? value[change] : change
                  xml.priority   value[priority] ? value[priority] : priority
               end                  
            end
         end
         content = xml.target!
         File.open(sitemap,"w") do |file|
            file << content
         end
         open("http://www.google.com/webmasters/tools/ping?sitemap=#{sitemapper[:url]}").read if sitemapper[:url]
         content
      end
   end

   def self.included(where)
      class << where
         attr_accessor :sitemapper
      end
      where.extend(ClassMethods)
      where.sitemapper = {}
      where.sitemapper[:url]        = nil
      where.sitemapper[:loc]        = :loc
      where.sitemapper[:lastmod]    = :lastmod
      where.sitemapper[:changefreq] = "daily"
      where.sitemapper[:priority]   = 1.00
   end
end
