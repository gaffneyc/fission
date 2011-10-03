module Fission
  class Command
    class Clone < Command

      def initialize(args=[])
        super
        @options.start = false
      end

      def execute
        option_parser.parse! @args

        unless @args.count > 1
          output self.class.help
          output ''
          output_and_exit 'Incorrect arguments for clone command', 1
        end

        source_vm = @args.first
        target_vm = @args[1]

        exists_response = Fission::VM.exists? source_vm

        if exists_response.successful?
          unless exists_response.data
            output_and_exit "Unable to find the VM '#{source_vm}' (#{Fission::VM.path(source_vm)})", 1 
          end
        end

        exists_response = Fission::VM.exists? target_vm

        if exists_response.successful?
          if exists_response.data
            output_and_exit "The target VM '#{target_vm}' already exists", 1
          end
        end

        clone_response = Fission::VM.clone source_vm, target_vm

        if clone_response.successful?
          output ''
          output 'Clone complete!'

          if @options.start
            output "Starting '#{target_vm}'"
            vm = Fission::VM.new target_vm

            start_response = vm.start

            if start_response.successful?
              output "VM '#{target_vm}' started"
            else
              output_and_exit "There was an error starting the VM.  The error was:\n#{start_response.output}", start_response.code
            end
          end
        else
          output_and_exit "There was an error cloning the VM.  The error was:\n#{clone_response.output}", clone_response.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nclone usage: fission clone source_vm target_vm [options]"

          opts.on '--start', 'Start the VM after cloning' do
            @options.start = true
          end
        end

        optparse
      end

    end
  end
end
