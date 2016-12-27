require 'skippy/app'
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
# Skippy will list all known commands when invoked without any arguments.
#
# The code in this class will often refer to thor - when things have been copied
# verbatim. Makes it easier to update if needed.
class Skippy::CLI < Skippy::Command

  class << self

    # @param [Skippy::Error] error
    def display_error(error)
      shell = Thor::Base.shell.new
      message = " #{error.message} "
      message = shell.set_color(message, :white)
      message = shell.set_color(message, :on_red)
      shell.error message
    end

  end # Class methods

  default_command :list

  # Verbatim copy from Thor::Runner:
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

  # Verbatim copy from Thor::Runner:
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

  # Verbatim copy from Thor::Runner:
  desc "list [SEARCH]", "List the available #{$PROGRAM_NAME} commands (--substring means .*SEARCH)"
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

  # Based on Thor::Runner, with exception of program name.
  def self.banner(command, all = false, subcommand = false)
    "#{$PROGRAM_NAME} " + command.formatted_usage(self, all, subcommand)
  end

  # Verbatim copy from Thor::Runner:
  def self.exit_on_failure?
    true
  end

  # This is one of the places this runner differ from Thor::Runner. It will
  # instead load files for the current project.
  #
  # TODO(thomthom): Original arguments kept around for now, so avoid altering
  # the methods that calls this. It might be that these arguments might be
  # useful for optimizations later.
  def initialize_thorfiles(_relevant_to = nil, _skip_lookup = false)
    project = Skippy::Project.new(Dir.pwd)
    return unless project.exist?
    project.command_files { |filename|
      unless Thor::Base.subclass_files.keys.include?(File.expand_path(filename))
        Thor::Util.load_thorfile(filename, nil, options[:debug])
      end
    }
  end

  def display_app_banner
    program_name = shell.set_color($PROGRAM_NAME.capitalize, :green)
    version = shell.set_color('version', :clear)
    program_version = shell.set_color(Skippy::VERSION, :yellow)
    say "#{program_name} #{version} #{program_version}"
  end

  # Based on Thor::Runner:
  def display_klasses(with_modules = false, show_internal = false, klasses = Thor::Base.subclasses)
    unless show_internal
      klasses -= [
        Thor, Thor::Runner, Thor::Group,
        Skippy, Skippy::CLI, Skippy::Command, Skippy::Command::Group
      ]
    end

    fail Error, "No #{$PROGRAM_NAME.capitalize} commands available" if klasses.empty?

    list = Hash.new { |h, k| h[k] = [] }
    groups = klasses.select { |k| k.ancestors.include?(Thor::Group) }

    # Get classes which inherit from Thor
    (klasses - groups).each { |k|
      list[k.namespace.split(":").first] += k.printable_commands(false)
    }

    # Get classes which inherit from Thor::Base
    groups.map! { |k| k.printable_commands(false).first }
    # Thor:Runner put these under 'root', but here we just avoid any name at
    # all together.
    list[''] = groups

    display_app_banner
    say
    say 'Available commands:', :yellow

    # Align all command descriptions. This means computing a fixed width for
    # the first column.
    col_width = list.map { |_, rows|
      rows.map { |col| col.first.size }.max || 0
    }.max

    # Order namespaces with default coming first
    list = list.sort { |a, b|
      a[0].sub(/^default/, "") <=> b[0].sub(/^default/, "")
    }
    list.each { |n, commands|
      display_commands(n, commands, col_width) unless commands.empty?
    }
  end

  # Based on Thor::Runner:
  def display_commands(namespace, list, col_width)
    list.sort! { |a, b| a[0] <=> b[0] }

    say shell.set_color(namespace, :yellow, true) unless namespace.empty?

    list.each { |row|
      row[0] = shell.set_color(row[0], :green) + shell.set_color('', :clear)
    }
    # TODO(thomthom): For some reason the column appear as half the width.
    # Not sure why, so for now we apply this hack.
    # TODO(thomthom): Because of the odd issue with col_width mentioned in
    # `display_klasses` the table isn't truncated. Can probably re-enable if
    # the col_width issue is fixed.
    #print_table(list, :truncate => true, :indent => 2, :colwidth => col_width)
    width = (col_width + 2) * 2
    print_table(list, :indent => 2, :colwidth => width)
  end
  alias_method :display_tasks, :display_commands

  # Based on Thor::Runner, skipping the yaml stuff:
  def show_modules
    info  = []
    labels = %w[Modules Namespaces]

    info << labels
    info << ["-" * labels[0].size, "-" * labels[1].size]

    print_table info
    say ""
  end

end
