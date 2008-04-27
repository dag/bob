begin
  require 'rubygems'
rescue LoadError
end

require 'builder'
require 'rexml/document'
require 'yaml'

module Bob
  class Package
    attr_accessor :name, :version, :release, :dependencies

    def initialize(opts={})
      if opts.include? :yaml
        from_yaml(File.new(opts[:yaml]))
      elsif opts.include? :xml
        from_xml(File.new(opts[:xml]))
      end
    end

    def from_yaml(io)
      yaml = YAML.load(io)

      @name = yaml["name"]
      @version = yaml["version"]
      @release = yaml["release"]

      @dependencies = []
      yaml["dependencies"].each do |dependency|
        dependency = dependency.split(" ")
        @dependencies << {}
        @dependencies[-1][:name] = dependency[0]
        @dependencies[-1][:version] = dependency[1]
      end
    end

    def from_xml(io)
    end

    def to_yaml
      {
        "name" => @name,
        "version" => @version,
        "release" => @release,
        "dependencies" => @dependencies.map {|d| [d[:name], d[:version]].join(" ") }
      }.to_yaml
    end

    def to_xml
      xml = String.new
      builder = Builder::XmlMarkup.new(:indent => 2, :target => xml)
      pkgid = Array.new(40).map { ([*0..9] + [*"a".."f"])[rand(16)].to_s }.join

      builder.instruct!

      builder.package(:id => pkgid) {
        builder.name(@name)
        builder.version(@version)
        builder.release(@release)

        builder.dependencies {
          @dependencies.each {|d| builder.dependency(d) }
        }
      }

      xml
    end
  end
end
