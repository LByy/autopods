require "autopods/version"

require "audopods/command/check"

require 'gli'

include GLI::App

module AutoPods
  program_desc %{iOS application modulize into pods, improvement for develop modules. 
    CMD:
    1.git-flow
    2.auto publish code
    3.auto push repo
    4.auto rewrite podfile
    5.sync other branch commit
    6.binary static libary
  }

  current_exec_path = Dir.pwd()

  flag %i[p path], default_value: current_exec_path
  
  if ProcessOperator.already_in_process
  	Logger.error("There is another 'autopods' command in process, please wait")
  	exit()
  end

  check_command()

  desc "Show podsorz version"
  command :version do |version|
  	version.action do |global_options, options, args|
  		p VERSION
  	end
  end

  exit run(ARGV)
end

