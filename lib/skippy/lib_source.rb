require 'digest'
require 'net/http'
require 'pathname'
require 'uri'

require 'skippy/error'
require 'skippy/library'

class Skippy::LibrarySource

  attr_reader :origin

  class LibraryNotFoundError < Skippy::Error; end

  # @param [Skippy::Project] project
  # @param [Pathname, String] source
  # @param [Hash] options
  def initialize(project, source, options = {})
    @project = project
    @origin = resolve(source.to_s)
    @options = options
  end

  def git?
    git_source?(@origin)
  end

  def local?
    local_source?(@origin)
  end

  def relative?
    local? && Pathname.new(@origin).relative?
  end

  def absolute?
    !relative?
  end

  # @return [String, nil]
  def version
    return nil if @options[:version].nil?
    # Normalize the version requirement pattern.
    parts = Gem::Requirement.parse(@options[:version])
    # .parse will from '1.2.3' return ['=', '1.2.3']. Don't need that.
    parts.delete('=')
    parts.join(' ')
  rescue Gem::Requirement::BadRequirementError
    @options[:version]
  end

  # @return [String]
  def branch
    @options[:branch]
  end

  # @param [String]
  def basename
    if local?
      Pathname.new(@origin).basename
    else
      uri = URI.parse(@origin)
      Pathname.new(uri.path).basename('.git')
    end
  end

  # @param [String]
  def lib_path
    if local?
      source = File.expand_path(@origin)
      hash_signature = Digest::SHA1.hexdigest(source)
      "#{basename}_local_#{hash_signature}"
    else
      # https://github.com/thomthom/tt-lib.git
      #         ^^^^^^^^^^ ^^^^^^^^ ^^^^^^
      #        source_name  author  basename
      uri = URI.parse(@origin)
      source_name = uri.hostname.gsub(/[.]/, '-')
      author = Pathname.new(uri.path).parent.basename
      "#{basename}_#{author}_#{source_name}"
    end
  end

  # @param [String]
  def to_s
    @origin.to_s
  end

  private

  # @param [String] source
  def resolve(source)
    if git_source?(source)
      resolve_from_git_uri(source)
    elsif local_source?(source)
      source
    else
      resolve_from_lib_name(source, @project.sources)
    end
  end

  # @param [String] source
  def git_source?(source)
    source.end_with?('.git')
  end

  # @param [String] source
  def local_source?(source)
    File.exist?(source)
  end

  # @param [String] source
  # @return [String]
  def resolve_from_git_uri(source)
    uri = URI.parse(source)
    # When logged in, BitBucket will display a URI with the user's username.
    uri.user = ''
    uri.to_s
  end

  # @param [String] source
  # @return [String]
  def resolve_from_lib_name(source, domains)
    domains.each { |domain|
      uri_str = "https://#{domain}/#{source}.git"
      uri = URI.parse(uri_str)
      response = Net::HTTP.get_response(uri)
      return uri_str if response.is_a?(Net::HTTPSuccess) ||
                        response.is_a?(Net::HTTPRedirection)
    }
    raise LibraryNotFoundError, "Library '#{source}' not found"
  end

end
