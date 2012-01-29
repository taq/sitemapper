require "rubygems"
require "nokogiri"
require "active_record"
require "minitest/spec"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/taq-sitemapper.rb"

ActiveRecord::Base.establish_connection({ 
   adapter: "sqlite3",
   database: "#{File.expand_path(File.dirname(__FILE__))}/taq-sitemapper.sqlite"
})

class SitemapperTestAR < ActiveRecord::Base  
   include SiteMapper

   sitemap[:changefreq] = :freq
   sitemap[:priority] = :priority

   def self.sitemap_extra
      [{loc: "Four"  , lastmod: Time.now, freq: "yearly", priority: 0.5}, 
       {loc: "Five"  , lastmod: Time.now, freq: "yearly", priority: 0.5}] 
   end
   def loc
      url
   end
end

def get_xml_doc(file)   
   Nokogiri::XML(File.open(file))
end

def get_elements_num(file,element)
   get_xml_doc(file).search(element).size
end

def delete_and_write(file,object,data=nil,extras=nil)
   File.unlink(file) if File.exists?(file)
   object.send(:write_sitemap,data,extras)
end

describe SiteMapper do
   before do
      @data =   [{url: "One"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                 {url: "Two"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
                 {url: "Three", lastmod: Time.now, freq: "monthly", priority: 1}]
      @extras = [{url: "Four" , lastmod: Time.now, freq: "yearly", priority: 0.5}, 
                 {url: "Five" , lastmod: Time.now, freq: "yearly", priority: 0.5}]
   end

   describe "Class option" do
      before do
         @sitemapper = SiteMapper::SiteMapper.new
         @sitemapper.url = "http://localhost.com/sitemap.xml"
         @sitemapper.loc = :url
         @sitemapper.changefreq = :freq
         @sitemapper.priority = :priority
         @sitemapper.file = "/tmp/sitemap.xml"
      end

      describe "when asked to write the sitemap file" do
         it "should write it with no extra options" do
            delete_and_write(@sitemapper.file,@sitemapper,@data.entries)
            assert File.exists?(@sitemapper.file), "sitemap file not found"
         end

         it "should write it with extra options" do
            delete_and_write(@sitemapper.file,@sitemapper,@data.entries,@extras.entries)
            assert File.exists?(@sitemapper.file), "sitemap file not found"
         end
      end

      describe "when the sitemap file is written" do
         before do
            delete_and_write(@sitemapper.file,@sitemapper,@data.entries,@extras.entries)
            @sitemapper.write_sitemap(@data.entries,@extras.entries) 
         end

         it "should have the correct url size" do
            get_elements_num(@sitemapper.file,"url").must_equal @data.size+@extras.size, 
         end

         it "should have the correct loc size" do
            get_elements_num(@sitemapper.file,"url").must_equal @data.size+@extras.size 
         end

         it "should have the correct changefreq size" do
            get_elements_num(@sitemapper.file,"changefreq").must_equal @data.size+@extras.size
         end

         it "should have the correct lastmod size" do
            get_elements_num(@sitemapper.file,"lastmod").must_equal @data.size+@extras.size 
         end

         it "should have the correct priority size" do
            get_elements_num(@sitemapper.file,"priority").must_equal @data.size+@extras.size
         end

         it "should write the correct locs" do
            elements = get_xml_doc(@sitemapper.file).search("loc")
            for item in (@extras+@data)
               elements.shift.text.must_equal item[:url]
            end
         end

         it "should write the correct lastmod" do
            elements = get_xml_doc(@sitemapper.file).search("lastmod")
            for item in (@extras+@data)
               elements.shift.text.must_equal item[:lastmod].to_s
            end
         end

         it "should write the correct changefreq" do
            elements = get_xml_doc(@sitemapper.file).search("changefreq")
            for item in (@extras+@data)
               elements.shift.text.must_equal item[:freq]
            end
         end

         it "should write the correct priority" do
            elements = get_xml_doc(@sitemapper.file).search("priority")
            for item in (@extras+@data)
               elements.shift.text.must_equal item[:priority].to_s
            end
         end
      end
   end

   describe "Module option" do
      describe "when asked to write the sitemap file"  do
          it "show write with no extras" do
            delete_and_write(SitemapperTestAR.sitemap[:file],SitemapperTestAR)
            assert File.exists?(SitemapperTestAR.sitemap[:file]), "sitemap file not found"
          end

          it "show write with extras" do
            SitemapperTestAR.sitemap[:extra] = :sitemap_extra
            delete_and_write(SitemapperTestAR.sitemap[:file],SitemapperTestAR)
            assert File.exists?(SitemapperTestAR.sitemap[:file]), "sitemap file not found"
          end
      end

      describe "when asked about the attributes" do
         it "should have the module base methods" do
            SitemapperTestAR.must_respond_to :write_sitemap
            SitemapperTestAR.must_respond_to :ping
         end

         it "should have the sitemap attribute" do
            SitemapperTestAR.must_respond_to :sitemap
         end

         it "should have the all method as the collection method" do
            SitemapperTestAR.sitemap[:collection].must_equal :all
         end
      end
   end
end
