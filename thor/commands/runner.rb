require 'skippy/command'

require_relative 'sketchup/project'

class Skippy::Runner < Skippy::Command

  # If a command is not found on Thor::Runner, method missing is invoked and
  # Thor::Runner is then responsible for finding the command in all classes.
  #
  def method_missing(meth, *args)
    meth = meth.to_s
    initialize_thorfiles(meth)
    klass, command = Thor::Util.find_class_and_command_by_namespace(meth)
    self.class.handle_no_command_error(command, false) if klass.nil?
    args.unshift(command) if command
    klass.start(args, :shell => shell)
  end

  desc "list [SEARCH]", "List the available thor commands (--substring means .*SEARCH)"
  method_options :substring => :boolean, :group => :string, :all => :boolean, :debug => :boolean
  def list(search = "")
    initialize_thorfiles

    search = ".*#{search}" if options["substring"]
    search = /^#{search}.*/i
    group  = options[:group] || "standard"

    klasses = Thor::Base.subclasses.select do |k|
      (options[:all] || k.group == group) && k.namespace =~ search
    end

    display_klasses(false, false, klasses)
  end

  private

  def self.banner(command, all = false, subcommand = false)
    "#{$PROGRAM_NAME} " + command.formatted_usage(self, all, subcommand)
  end

  def thor_root
    Thor::Util.thor_root
  end

  def self.exit_on_failure?
    true
  end

  # Load the Thorfiles. If relevant_to is supplied, looks for specific files
  # in the thor_root instead of loading them all.
  #
  # By default, it also traverses the current path until find Thor files, as
  # described in thorfiles. This look up can be skipped by supplying
  # skip_lookup true.
  #
  def initialize_thorfiles(relevant_to = nil, skip_lookup = false)
    #thorfiles(relevant_to, skip_lookup).each do |f|
    #  Thor::Util.load_thorfile(f, nil, options[:debug]) unless Thor::Base.subclass_files.keys.include?(File.expand_path(f))
    #end
    project = Skippy::Project.new(Dir.pwd)
    if project.exist?
      project.command_files { |filename|
        unless Thor::Base.subclass_files.keys.include?(File.expand_path(filename))
          Thor::Util.load_thorfile(filename, nil, options[:debug])
        end
      }
    end
  end

  # Display information about the given klasses. If with_module is given,
  # it shows a table with information extracted from the yaml file.
  #
  def display_klasses(with_modules = false, show_internal = false, klasses = Thor::Base.subclasses)
    klasses -= [Thor, Thor::Runner, Thor::Group] unless show_internal

    fail Error, "No Thor commands available" if klasses.empty?
    show_modules if with_modules #&& !thor_yaml.empty?

    list = Hash.new { |h, k| h[k] = [] }
    groups = klasses.select { |k| k.ancestors.include?(Thor::Group) }

    # Get classes which inherit from Thor
    (klasses - groups).each { |k| list[k.namespace.split(":").first] += k.printable_commands(false) }

    # Get classes which inherit from Thor::Base
    groups.map! { |k| k.printable_commands(false).first }
    list["root"] = groups

    # Order namespaces with default coming first
    list = list.sort { |a, b| a[0].sub(/^default/, "") <=> b[0].sub(/^default/, "") }
    list.each { |n, commands| display_commands(n, commands) unless commands.empty? }
  end

  def display_commands(namespace, list) #:nodoc:
    list.sort! { |a, b| a[0] <=> b[0] }

    say shell.set_color(namespace, :blue, true)
    say "-" * namespace.size

    print_table(list, :truncate => true)
    say
  end
  alias_method :display_tasks, :display_commands

  def show_modules #:nodoc:
    info  = []
    labels = %w[Modules Namespaces]

    info << labels
    info << ["-" * labels[0].size, "-" * labels[1].size]

    #thor_yaml.each do |name, hash|
    #  info << [name, hash[:namespaces].join(", ")]
    #end

    print_table info
    say ""
  end
  
end
