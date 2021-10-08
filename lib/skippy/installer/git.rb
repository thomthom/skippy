# frozen_string_literal: true

require 'git'
require 'naturally'
require 'pathname'

require 'skippy/error'
require 'skippy/installer'
require 'skippy/library'

module Skippy

  class BranchNotFound < Skippy::Error; end
  class TagNotFound < Skippy::Error; end

end

class Skippy::GitLibraryInstaller < Skippy::LibraryInstaller

  # @return [Skippy::Library]
  def install
    info "Installing #{source.basename} from #{source.origin}..."
    target = path.join(source.lib_path)
    previous_commit = nil
    if target.directory?
      git, previous_commit = update_repository(target)
    else
      git = clone_repository(source.origin, target)
    end
    begin
      checkout_branch(git, source.branch) if source.branch
      checkout_tag(git, source.requirement) unless edge_version?(source.requirement) # rubocop:disable Metrics/LineLength
    rescue Skippy::Error
      git.checkout(previous_commit) if previous_commit
      raise
    end
    library = Skippy::Library.new(target, source: source)
    library
  end

  private

  # @param [URI] uri
  # @param [Pathname] target
  # @return [Git::Base]
  def clone_repository(uri, target)
    info 'Cloning...'
    Git.clone(uri, target.basename, path: target.parent)
  end

  # @param [Pathname] target
  # @return [Array(Git::Base, Git::Commit)]
  def update_repository(target)
    info 'Updating...'
    library = Skippy::Library.new(target)
    info "Current version: #{library.version}"
    git = Git.open(target)
    previous_commit = git.object('HEAD^').class
    git.reset_hard
    git.fetch
    [git, previous_commit]
  end

  # @param [Git::Base]
  # @param [String] branch
  def checkout_branch(git, branch)
    branches = git.branches.map(&:name)
    info "Branches: #{branches.inspect}"
    unless branches.include?(branch)
      raise Skippy::BranchNotFound, "Found no branch named: '#{branch}'"
    end

    git.checkout(branch)
    nil
  end

  # @param [Git::Base]
  # @param [String] version
  def checkout_tag(git, version)
    tags = Naturally.sort_by(git.tags, :name)
    tag = latest_version?(version) ? tags.last : resolve_tag(tags, version)
    raise Skippy::TagNotFound, "Found no version: '#{version}'" if tag.nil?

    git.checkout(tag)
    # Verify the library version with the tagged version.
    target = path.join(source.lib_path)
    library = Skippy::Library.new(target)
    unless library.version.casecmp(tag.name).zero?
      warning "skippy.json version (#{library.version}) differ from "\
              "tagged version (#{tag.name})"
    end
    nil
  end

  # Resolve version numbers like RubyGem.
  #
  # @param [Array<Git::Tag>] tags List of tags sorted with newest first
  # @param [String] version
  # @return [Git::Tag]
  def resolve_tag(tags, version)
    requirement = Gem::Requirement.new(version)
    tags.reverse.find { |tag|
      next false unless Gem::Version.correct?(tag.name)

      tag_version = Gem::Version.new(tag.name)
      requirement.satisfied_by?(tag_version)
    }
  end

  # @param [String] version
  def edge_version?(version)
    version && version.casecmp('edge').zero?
  end

  # @param [String] version
  def latest_version?(version)
    version.nil? || version.casecmp('latest').zero?
  end

end
