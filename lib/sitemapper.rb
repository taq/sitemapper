require "builder"
require "open-uri"

module SiteMapper
   module ClassMethods
      def write_sitemap(sitemap,meth,extras=nil,extra_meth=nil)
         xml         = Builder::XmlMarkup.new(:indent=>2)
         extra_meth  = extra_meth ? extra_meth : meth
         col         = send(meth)
         col         = col + extras.send(extra_meth) if extras
         xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
            col.each do |value|
               loc      = value.respond_to?(sitemapper[:loc])        ? value.send(sitemapper[:loc])        : value[sitemapper[:loc]]
               lastmod  = value.respond_to?(sitemapper[:lastmod])    ? value.send(sitemapper[:lastmod])    : value[sitemapper[:lastmod]]
               change   = value.respond_to?(sitemapper[:changefreq]) ? value.send(sitemapper[:changefreq]) : value[sitemapper[:changefreq]]
               priority = value.respond_to?(sitemapper[:priority])   ? value.send(sitemapper[:priority])   : value[sitemapper[:priority]]
               xml.url do
                  xml.loc        loc
                  xml.lastmod    lastmod 
                  xml.changefreq change
                  xml.priority   priority
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
