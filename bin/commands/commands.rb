# frozen_string_literal: true

module Doing
  # commands command methods
  class CommandsCommand
    def add_examples(cmd)
      cmd.example 'doing commands add', desc: 'Get a menu of available commands'
      cmd.example 'doing commands add COMMAND', desc: 'Specify a command to enable'
      cmd.example 'doing commands remove COMMAND', desc: 'Specify a command to disable'
    end

    def remove_command(args)
      available = Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).map { |cmd| File.basename(cmd, '.rb') }
      cfg = Doing.settings
      custom_dir = Doing.setting('plugins.command_path')
      custom_commands = Dir.glob(File.join(File.expand_path(custom_dir), '*.rb'))
      available.concat(custom_commands.map { |cmd| File.basename(cmd, '.rb') })
      disabled = Doing.setting('disabled_commands')
      disabled.each { |cmd| available.delete(cmd) }
      to_disable = if args.good?
                     args
                   else
                     Prompt.choose_from(available,
                                        prompt: 'Select commands to enable',
                                        multiple: true,
                                        sorted: true)
                   end
      raise UserCancelled unless to_disable.good?

      to_disable = to_disable.strip.split("\n") if to_disable.is_a?(String)

      to_disable.each do |cmd|
        default_command = File.join(File.dirname(__FILE__), "#{cmd}.rb")
        custom_command = File.join(File.expand_path(custom_dir), "#{cmd}.rb")
        unless File.exist?(default_command) || File.exist?(custom_command)
          raise InvalidArgument, "Command #{cmd} not found"

        end

        raise InvalidArgument, "Command #{cmd} is not enabled" unless available.include?(cmd)
      end

      cfg.deep_set(['disabled_commands'], disabled.concat(to_disable))

      Util.write_to_file(Doing.config.config_file, YAML.dump(cfg), backup: true)
      Doing.logger.warn('Config:', "#{Doing.config.config_file} updated")
    end

    def add_command(args)
      cfg = Doing.settings
      custom_dir = Doing.setting('plugins.command_path')
      available = Doing.setting('disabled_commands')

      raise UserCancelled, 'No commands available to enable' unless args.good? || available.good?

      to_enable = if args.good?
                    args
                  else
                    Prompt.choose_from(available,
                                       prompt: 'Select commands to enable',
                                       multiple: true,
                                       sorted: true)
                  end
      raise UserCancelled unless to_enable.good?

      to_enable = to_enable.strip.split("\n") if to_enable.is_a?(String)

      to_enable.each do |cmd|
        default_command = File.join(File.dirname(__FILE__), "#{cmd}.rb")
        custom_command = File.join(File.expand_path(custom_dir), "#{cmd}.rb")
        unless File.exist?(default_command) || File.exist?(custom_command)
          raise InvalidArgument, "Command #{cmd} not found"
        end

        raise InvalidArgument, "Command #{cmd} is not disabled" unless available.include?(cmd)

        available.delete(cmd)
      end

      cfg.deep_set(['disabled_commands'], available)

      Util.write_to_file(Doing.config.config_file, YAML.dump(cfg), backup: true)
      Doing.logger.warn('Config:', "#{Doing.config.config_file} updated")
    end
  end
end

# @@commands
desc 'Enable and disable Doing commands'
command :commands do |c|
  c.default_command :add

  cmd = Doing::CommandsCommand.new

  cmd.add_examples(c)

  # @@commands.enable
  c.desc 'Enable Doing commands'
  c.long_desc 'Run without arguments to select commands from a list.'
  c.arg_name 'COMMAND [COMMAND...]'
  c.command %i[add enable] do |add|
    add.action do |_global, _options, args|
      cmd.add_command(args)
    end
  end

  # @@commands.disable
  c.desc 'Disable Doing commands'
  c.command %i[remove disable] do |remove|
    remove.action do |_global, _options, args|
      cmd.remove_command(args)
    end
  end
end
