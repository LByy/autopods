# require "podsorz/core/PodsOrz/pods_check_merge"
# require "../../PodsOrz/lib/podsorz/core/PodsOrz/pods_check_merge.rb"
require "audopods/core/pods_check_merge"

module AutoPods
	def self.check_command
		desc "Check Pods not merge"
		command :check do |check|
			check.action do |global_options, options, args|
				dir_path = global_options[:path]

				is_directory = File.directory?(dir_path)

				unless is_directory
					Logger.error("Check failure, it is not a directory path: #{dir_path}")
					exit()
				end

                kx_pods_path = File.expand_path("../kx_pods", dir_path)
                # puts "kx_pods_path #{kx_pods_path}"
				checkManger = AutoPods::PodsCheckMerge.new()
                checkManger.branchList(kx_pods_path)
			
			end
		end
	end

end
