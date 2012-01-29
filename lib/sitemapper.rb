require "builder"
require "open-uri"

module SiteMapper
   module BaseMethods
      def write_sitemap(collection=nil,extra_collection=nil)
         file_ref       = @file        || (@sitemap[:file] rescue nil)
         loc_ref        = @loc         || (@sitemap[:loc] rescue nil)
         lastmod_ref    = @lastmod     || (@sitemap[:lastmod] rescue nil)
         changefreq_ref = @changefreq  || (@sitemap[:changefreq] rescue nil)
         priority_ref   = @priority    || (@sitemap[:priority] rescue nil)

         return false if file_ref.nil?

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
         File.open(file_ref,"w") do |file|
            file << content
         end
         content
      end

      def ping
         url_ref = @url || (@sitemap[:url] rescue nil)
         return if url_ref.nil?
         open("http://www.google.com/webmasters/tools/ping?sitemap=#{url_ref}").read
      end
   end

   def self.included(where)
      where.extend(BaseMethods)   
      class << where
         attr_accessor :sitemap
      end
      where.sitemap = {}
      where.sitemap[:url]        = nil
      where.sitemap[:loc]        = :loc
      where.sitemap[:lastmod]    = :lastmod
      where.sitemap[:changefreq] = "daily"
      where.sitemap[:priority]   = 1.00
      where.sitemap[:sitemap]    = nil
   end

   class SiteMapper
      include BaseMethods
      attr_accessor :url, :loc, :lastmod, :changefreq, :priority, :file

      def initialize
         @url        = nil
         @loc        = :loc
         @lastmod    = :lastmod
         @changefreq = "daily"
         @priority   = 1.00
         @file       = nil
      end
   end
end
