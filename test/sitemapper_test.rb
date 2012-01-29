require "rubygems"
require "nokogiri"
require "test/unit"
require "active_record"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sitemapper.rb"

ActiveRecord::Base.establish_connection({ 
   adapter: "sqlite3",
   database: "/tmp/sitemapper.sqlite"
})

class SitemapperTestAR < ActiveRecord::Base  
   include SiteMapper
end

class SiteMapperTest < Test::Unit::TestCase
   def setup
      @arraytest = [{url: "One"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                    {url: "Two"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                    {url: "Three", lastmod: Time.now, freq: "monthly", priority: 1}]

      @sitemapper = SiteMapper::SiteMapper.new
      @sitemapper.url = "http://localhost.com/sitemap.xml"
      @sitemapper.loc = :url
      @sitemapper.changefreq = :freq
      @sitemapper.priority = :priority
      @sitemapper.file = "/tmp/sitemap.xml"
   end   

   def test_write_sitemap
      File.unlink(@sitemapper.file) if File.exists?(@sitemapper.file)
      @sitemapper.write_sitemap(@arraytest.entries) 
      assert File.exists?(@sitemapper.file), "sitemap file not found"
   end

   def test_url_size
      test_write_sitemap
      doc = Nokogiri::XML(File.open(@sitemapper.file))
      assert_equal @arraytest.entries.size, doc.search("url").size
   end

   def test_write_sitemap_with_extras
      File.unlink(@sitemapper.file) if File.exists?(@sitemapper.file)
      extras = [{url: "Four", lastmod: Time.now, freq: "yearly", priority: 0.5}, 
                {url: "Five", lastmod: Time.now, freq: "yearly", priority: 0.5}]
      @sitemapper.write_sitemap(@arraytest.entries,extras.entries) 
      doc = Nokogiri::XML(File.open(@sitemapper.file))
      assert_equal @arraytest.entries.size+extras.size, doc.search("url").size
   end

   def test_ar_class_methods
      assert_respond_to SitemapperTestAR, :write_sitemap
      assert_respond_to SitemapperTestAR, :ping
   end

   def test_ar_class_attrs
      assert_respond_to SitemapperTestAR, :sitemap
   end
   
   def test_rw_class_attrs
      str = "test"
      SitemapperTestAR.sitemap[:loc] = str
      assert_equal str, SitemapperTestAR.sitemap[:loc]
   end

   def test_class_methods_default_values
      assert_equal "daily", SitemapperTestAR.sitemap[:changefreq]
   end
end
