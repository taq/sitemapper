require "builder"
require "open-uri"

module SiteMapper
   module BaseMethods
      def write_sitemap(collection=nil,extra_collection=nil)
         sitemap_ref    = @sitemap     || @sitemap_sitemap
         loc_ref        = @loc         || @sitemap_loc
         lastmod_ref    = @lastmod     || @sitemap_lastmod
         changefreq_ref = @changefreq  || @sitemap_changefreq
         priority_ref   = @priority    || @sitemap_priority

         return false if sitemap_ref.nil?

         xml = Builder::XmlMarkup.new(:indent=>2)
         collection = extra_collection + collection if extra_collection

         xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
            collection.each do |value|
               loc      = value.respond_to?(loc_ref.to_s.to_sym)        ? value.send(loc_ref)        : value[loc_ref]
               lastmod  = value.respond_to?(lastmod_ref.to_s.to_sym)    ? value.send(lastmod_ref)    : value[lastmod_ref]
               change   = value.respond_to?(changefreq_ref.to_s.to_sym) ? value.send(changefreq_ref) : value[changefreq_ref]
               priority = value.respond_to?(priority_ref.to_s.to_sym)   ? value.send(priority_ref)   : value[priority_ref]

               change   = changefreq_ref  if !change
               priority = priority_ref    if !priority

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
         url_ref = @url || @sitemap_url
         return if url_ref.nil?
         open("http://www.google.com/webmasters/tools/ping?sitemap=#{url_ref}").read
      end
   end

   def self.included(where)
      where.extend(BaseMethods)   
      class << where
         attr_accessor :sitemap_url, :sitemap_loc, :sitemap_lastmod, 
                       :sitemap_changefreq, :sitemap_priority, 
                       :sitemap_sitemap
      end
      @sitemap_url        = nil
      @sitemap_loc        = :loc
      @sitemap_lastmod    = :lastmod
      @sitemap_changefreq = "daily"
      @sitemap_priority   = 1.00
      @sitemap_sitemap    = nil
   end

   class SiteMapper
      include BaseMethods
      attr_accessor :url, :loc, :lastmod, :changefreq, :priority, :sitemap

      def initialize
         @url        = nil
         @loc        = :loc
         @lastmod    = :lastmod
         @changefreq = "daily"
         @priority   = 1.00
         @sitemap    = nil
      end
   end
end
