require 'skippy/command'
require 'skippy/group'
require 'skippy/project'
require 'skippy/version'

# The Skippy::CLI class emulates much of what Thor::Runner do. It takes care of
# finding skippy projects and loading commands.
#
# The difference is mainly in how skippy vs thor present the commands.
#
# TODO(thomthom): ...or should it?
# Thor let you install commands globally, where as skippy does not.
#
# TODO(thomthom): Implement this:
# Skippy will list all known commands when invoked without any arguments.
#
# The code in this class will often refer to thor - when things have been copied
# verbatim. Makes it easier to update if needed.
class Skippy::CLI < Skippy::Command

  default_command :list

  # Override Thor#help so it can give information about any class and any method.
  #
  def help(meth = nil)
    if meth && !self.respond_to?(meth)
      initialize_thorfiles(meth)
      klass, command = Thor::Util.find_class_and_command_by_namespace(meth)
      self.class.handle_no_command_error(command, false) if klass.nil?
      klass.start(["-h", command].compact, :shell => shell)
    else
      super
    end
  end

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

    program_name = shell.set_color($PROGRAM_NAME.capitalize, :green)
    version = shell.set_color('version', :clear)
    program_version = shell.set_color(Skippy::VERSION, :yellow)
    #say "#{$PROGRAM_NAME.capitalize} version #{Skippy::VERSION}"
    say "#{program_name} #{version} #{program_version}"
    say
    say 'Available commands:', :yellow
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
    unless show_internal
      klasses -= [Thor, Thor::Runner, Thor::Group]
      klasses -= [Skippy, Skippy::CLI, Skippy::Command, Skippy::Command::Group]
    end

    fail Error, "No Thor commands available" if klasses.empty?
    #show_modules if with_modules #&& !thor_yaml.empty?

    list = Hash.new { |h, k| h[k] = [] }
    groups = klasses.select { |k| k.ancestors.include?(Thor::Group) }

    # Get classes which inherit from Thor
    (klasses - groups).each { |k|
      #list[k.namespace.split(":").first] += k.printable_commands(false)
      list[k.namespace.split(":").first] += k.cli_printable_commands(false)
    }

    # Get classes which inherit from Thor::Base
    #groups.map! { |k| k.printable_commands(false).first }
    #list["root"] = groups
    groups.map! { |k| k.cli_printable_commands(false).first }
    list[''] = groups
    #groups.each { |k|
      #p k.cli_printable_commands
      #p k.namespace
      # TODO(thomthom): Preserve original, but don't say "root", put at top.
      #list[k.namespace] += k.cli_printable_commands(false)
    #}

    # Order namespaces with default coming first
    col_width = list.map { |_, rows| rows.map { |col| col.first.size }.max }.max
    #p col_width
    #p list
    #puts JSON.pretty_generate(list)
    list = list.sort { |a, b| a[0].sub(/^default/, "") <=> b[0].sub(/^default/, "") }
    #list.each { |n, commands| display_commands(n, commands) unless commands.empty? }
    list.each { |n, commands|
      display_commands(n, commands, col_width * 2) unless commands.empty?
    }

    #say
  end

  def display_commands(namespace, list, col_width) #:nodoc:
    list.sort! { |a, b| a[0] <=> b[0] }

    #say shell.set_color(namespace, :blue, true)
    #say "-" * namespace.size
    say shell.set_color(namespace, :yellow, true) unless namespace.empty?

    list.each { |row|
      row[0] = shell.set_color(row[0], :green) + shell.set_color('', :clear)
    }
    #print_table(list, :truncate => true, :indent => 2, :colwidth => col_width)
    print_table(list, :indent => 2, :colwidth => col_width)
    #print_table(list, :colwidth => 40)
    #print_table(list, :truncate => true)
    #say
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
