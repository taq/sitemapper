require "nokogiri"
require "test/unit"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/site_mapper.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/collections.rb"

class SiteMapperTest < Test::Unit::TestCase
   def setup
      ArrayTest.new([{url: "One"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                     {url: "Two"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                     {url: "Three", lastmod: Time.now, freq: "monthly", priority: 1}])
      ArrayTest.sitemapper[:url] = "http://localhost.com/sitemap.xml"
      ArrayTest.sitemapper[:loc] = :url
      ArrayTest.sitemapper[:changefreq] = :freq
      ArrayTest.sitemapper[:priority] = :priority
   end   

   def test_write_sitemap_method
      assert_respond_to ArrayTest, :write_sitemap
   end

   def test_write_sitemap
      file = "/tmp/sitemap.xml"   
      File.unlink(file) if File.exists?(file)
      ArrayTest.write_sitemap(file,:values) 
      assert File.exists?(file), "sitemap file not found"
   end

   def test_url_size
      test_write_sitemap
      doc = Nokogiri::XML(File.open("/tmp/sitemap.xml"))
      assert_equal ArrayTest.values.size, doc.search("url").size
   end

   def test_write_sitemap_with_extras
      file = "/tmp/sitemap.xml"   
      File.unlink(file) if File.exists?(file)
      extras = [{url: "Four", lastmod: Time.now, freq: "monthly", priority: 1}, 
                {url: "Five", lastmod: Time.now, freq: "monthly", priority: 1}]
      ArrayTest.write_sitemap(file,:values,extras,:entries) 
      doc = Nokogiri::XML(File.open("/tmp/sitemap.xml"))
      assert_equal ArrayTest.values.size+extras.size, doc.search("url").size
   end
end
