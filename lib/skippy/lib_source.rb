# frozen_string_literal: true

require 'digest'
require 'net/http'
require 'pathname'
require 'uri'

require 'skippy/error'
require 'skippy/library'
require 'skippy/os'

class Skippy::LibrarySource

  attr_reader :origin, :options

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
  def requirement
    return nil if @options[:requirement].nil?

    # Normalize the version requirement pattern.
    parts = Gem::Requirement.parse(@options[:requirement])
    # .parse will from '1.2.3' return ['=', '1.2.3']. Don't need that.
    parts.delete('=')
    parts.join(' ')
  rescue Gem::Requirement::BadRequirementError
    @options[:requirement]
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
    os = Skippy::OS.new
    source = os.normalize_path(source)
    if git_source?(source)
      resolve_from_git_uri(source)
    elsif lib_name?(source)
      resolve_from_lib_name(source, @project.sources)
    else
      source
    end
  end

  # @param [String] source
  def git_source?(source)
    source.end_with?('.git') || Pathname.new(source).join('.git').exist?
  end

  # @param [String] source
  def local_source?(source)
    File.exist?(source)
  end

  # @param [String] source
  def lib_name?(source)
    !local_source?(source) && source =~ %r{^[^/]+/[^/]+$}
  end

  # @param [String] source
  # @return [String]
  def resolve_from_git_uri(source)
    # This can be a local Windows path, normalize path separators to allow the
    # path to be parsed.
    normalized = source.tr('\\', '/')
    uri = URI.parse(normalized)
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
