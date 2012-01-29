require "rubygems"
require "active_record"
require "taq-sitemapper"

ActiveRecord::Base.establish_connection({ 
   adapter: "sqlite3",
   database: "../test/taq-sitemapper.sqlite"
})

class SitemapperTestAR < ActiveRecord::Base  
   include SiteMapper
   sitemap[:file] = "/tmp/sitemap_module.xml"
   sitemap[:changefreq] = :freq
   sitemap[:priority] = :priority

   after_save :write_sitemap
   
   def self.sitemap_extra
      [{loc: "Four", lastmod: Time.now, freq: "yearly", priority: 0.5}, 
       {loc: "Five", lastmod: Time.now, freq: "yearly", priority: 0.5}, 
       {loc: "Six" , lastmod: Time.now, freq: "yearly", priority: 0.5}]
   end

   def loc
      url
   end

   def write_sitemap
      self.class.write_sitemap
   end
end
SitemapperTestAR.write_sitemap

# extra data
SitemapperTestAR.sitemap[:extra] = :sitemap_extra
SitemapperTestAR.sitemap[:file]  = "/tmp/sitemap_module_extra.xml"
SitemapperTestAR.write_sitemap

SitemapperTestAR.sitemap[:file]  = "/tmp/sitemap_module_extra_after_save.xml"
first = SitemapperTestAR.first
first.save
