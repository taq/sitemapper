require "rubygems"
require "nokogiri"
require "active_record"
require "minitest/spec"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/taq-sitemapper.rb"

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
end
