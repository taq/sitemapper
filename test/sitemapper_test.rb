require "nokogiri"
require "test/unit"
require "#{File.expand_path(File.dirname(__FILE__))}/collections.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sitemapper.rb"

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
      @sitemapper.sitemap = "/tmp/sitemap.xml"
   end   

   def test_write_sitemap
      File.unlink(@sitemapper.sitemap) if File.exists?(@sitemapper.sitemap)
      @sitemapper.write_sitemap(@arraytest.entries) 
      assert File.exists?(@sitemapper.sitemap), "sitemap file not found"
   end

   def test_url_size
      test_write_sitemap
      doc = Nokogiri::XML(File.open(@sitemapper.sitemap))
      assert_equal @arraytest.entries.size, doc.search("url").size
   end

   def test_write_sitemap_with_extras
      File.unlink(@sitemapper.sitemap) if File.exists?(@sitemapper.sitemap)
      extras = [{url: "Four", lastmod: Time.now, freq: "yearly", priority: 0.5}, 
                {url: "Five", lastmod: Time.now, freq: "yearly", priority: 0.5}]
      @sitemapper.write_sitemap(@arraytest.entries,extras.entries) 
      doc = Nokogiri::XML(File.open(@sitemapper.sitemap))
      assert_equal @arraytest.entries.size+extras.size, doc.search("url").size
   end
end
