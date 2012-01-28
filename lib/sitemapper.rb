require "builder"
require "open-uri"

module SiteMapper
   class SiteMapper
      attr_accessor :url, :loc, :lastmod, :changefreq, :priority, :sitemap

      def initialize
         @url        = nil
         @loc        = :loc
         @lastmod    = :lastmod
         @changefreq = "daily"
         @priority   = 1.00
         @sitemap    = nil
      end

      def write_sitemap(collection,extra_collection=nil)
         return false if @sitemap.nil?

         xml = Builder::XmlMarkup.new(:indent=>2)
         collection = extra_collection + collection if extra_collection

         xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
            collection.each do |value|
               loc      = value.respond_to?(@loc.to_s.to_sym)        ? value.send(@loc)        : value[@loc]
               lastmod  = value.respond_to?(@lastmod.to_s.to_sym)    ? value.send(@lastmod)    : value[@lastmod]
               change   = value.respond_to?(@changefreq.to_s.to_sym) ? value.send(@changefreq) : value[@changefreq]
               priority = value.respond_to?(@priority.to_s.to_sym)   ? value.send(@priority)   : value[@priority]

               change   = @changefreq  if !change
               priority = @priority    if !priority

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
         content
      end

      def ping
         return if @url.nil?
         open("http://www.google.com/webmasters/tools/ping?sitemap=#{@url}").read
      end
   end
end
