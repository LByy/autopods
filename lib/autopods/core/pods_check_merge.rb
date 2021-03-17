require 'open3'
require 'pathname'
require "autopods/util/git_operator"

module AutoPods

  class PodsCheckMerge

    # def check_Podfile(filePath)
    #   # 返回 path 的绝对路径，扩展 ~ 为进程所有者的主目录，~user 为用户的主目录。相对路径是相对于 dir 指定的目录，如果 dir 被省略则相对于当前工作目录
    #   tempPath = File.expand_path("Podfile",filePath)
    #   result = File::exist?tempPath
    #   if result
    #     puts("存在-- #{tempPath}")
    #   else
    #     puts("不存在-- #{tempPath}")
    #   end
    #   tempPath
    # end

    def branchList(path)
      list = []
      # IO.popen("cd '#{path}';git branch -r") do |io|
      #   io.each do |line|
      #     puts("branch -- #{line}")
      #     # has_branch = true if line.include? branch_name
      #   end
      # end

      # Open3.popen3("cd '#{File.dirname(__FILE__ )}';git branch -r"){|stdin, stdout, stderr, wait_thr|
      #   while line = stdout.gets
      #     puts("branch- #{line}")
      #   end
      # }
    #   @kx_pods_directory = File.expand_path("../kx_pods", File.dirname(__FILE__))
    #   puts "里层 #{@kx_pods_directory}"

#       kx_pods_path /Users/yuyutao/Desktop/rubyGem/kx_pods
# 里层 /Library/Ruby/Gems/2.6.0/gems/podsorz-0.0.5/lib/podsorz/core/kx_pods

      # dir = Dir.open("#{@kx_pods_directory}")
      # while name = dir.read
      #   p name
      # end
      # dir.close

    #   @kx_pods_directory = "/Users/yuyutao/Desktop/rubyGem/kx_pods"

      Dir.open("#{path}") do |dir|
        tempAry = ['.','..']
        dirAry = dir.to_a 
        ary = dirAry-tempAry
        ary.each do |name|
            dir_path = "#{path}/#{name}"
            is_directory = File.directory?(dir_path)
  
            if is_directory
              localBranch("#{dir_path}",name)
            else
            #   puts "#{name} 空文件"
            end
        end
        
      end
      

    end

    # git log -n1 --format=format:"%H"
    def localBranch(filePath,fileName)

        @git_operator = AutoPods::GitOperator.new()
	    has_changes = @git_operator.has_changes(filePath)
        if has_changes
            branch = @git_operator.current_branch(filePath)
            Logger.error("【#{filePath}】 on branch: \"#{branch}\" has unstaged/uncommit changes, please staged and commit local first")
            return      
        end

        is_merge_all = true
        branch = ""
        Open3.popen3("cd '#{filePath}';git branch -l"){|stdin, stdout, stderr, wait_thr|
            if stdout.gets
                while line = stdout.gets

                if line.include? "master"
                #   puts("master分支-#{fileName}")
                elsif line.include? "develop"
                #   puts("develop分支-#{fileName}")
                elsif line.include? "release"
                #   puts("release分支-#{fileName}")
                else
                # puts("#{fileName} branch- #{line}")
                    branch = line.strip
                    if branch.include? "*"
                        branch.delete!("*",)
                    end
                    is_merge_all = git_isMerged("#{branch}",filePath)
                end

          end
          
        else
        #   puts("未发现本地分支-#{fileName}")
        end
     }

    #   puts("all commit success!") if is_merge_all
        if is_merge_all

            puts("check result: all commit success! #{filePath}")
        else
            Logger.warning("#{filePath} - #{branch} commit not merge")
        end

    end

    def git_isMerged(branch,path)
      merge_destination_branch = "origin/develop"
      merge_source_branch = "#{branch}"
      merge_base = ""
      merge_current_commit = ""
      is_merge_all = true
      cmd = "cd '#{path}';git merge-base #{merge_destination_branch} #{branch}"
      IO.popen(cmd) do |io|
        io.each do |line|
          if line
            merge_base = line
          else
            puts("git merge-base 无hash值 #{path}")
          end
          
        end
      
      end
      cmd = "git rev-parse #{branch}"
      IO.popen("cd '#{path}';#{cmd}") do |io|
        io.each do |line|
          if line
            merge_current_commit = line
          else
            puts("git rev-parse 无hash值 #{path}")
          end
          
        end
      
      end

      if merge_base == merge_current_commit

      else
        is_merge_all = false
      end

      is_merge_all
    end

  end

end