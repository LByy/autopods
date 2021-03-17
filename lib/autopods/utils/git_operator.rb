require "autopods/util/logger"

module AutoPods

  class GitOperator
    def current_branch(path)
      Dir.chdir(path) do
        `git rev-parse --abbrev-ref HEAD`.chop
      end
    end

    def has_remote_branch(path, branch_name)
      has_branch = false
      IO.popen("cd '#{path}';git fetch --all;git branch -r") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end

        io.close
      end
      has_branch
    end

    def has_local_branch(path, branch_name)
      has_branch = false
      IO.popen("cd '#{path}';git branch") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end

        io.close
      end
      has_branch
    end

    def has_branch(path, branch_name)
      has_branch = false
      IO.popen("cd '#{path}';git fetch --all;git branch -a") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end

        io.close
      end
      has_branch
    end

    def checkout(path, branch_name)
      is_checkout_success = true
      Dir.chdir(path) do
        IO.popen("git checkout #{branch_name}") do |io|
          io.each do |line|
            if line.include? 'error'
              Logger.error("Checkout #{branch_name} failed.") 
              is_checkout_success = false
            end

            if line.include? 'fatal'
              Logger.error("Checkout #{branch_name} failed.") 
              is_checkout_success = false
            end

          end

          io.close
        end
      end

      is_checkout_success
    end

    def commit(path, message)
      Dir.chdir(path) do
        `git add .`
        `git commit -m "#{message}"`
      end
    end

    def push_to_remote(path, branch_name)
      is_push_success = true

      push_lines = []
      IO.popen("cd #{path};git push -u origin #{branch_name}") do |io|
        push_lines = io.readlines
        io.each do |line|
          if line.include? "error"
            is_push_success = false 
          end

          if line.include? "fatal"
            is_push_success = false
          end
        end

        io.close
      end

      unless is_push_success
        Logger.error("#{branch_name} push to remote failed!") 
        push_lines.each do |line|
          puts(line)
        end
      end

      is_push_success
    end

    def push_personal_force_to_remote(path, branch_name)
      is_push_success = true

      push_lines = []
      IO.popen("cd #{path};git push -u -f origin #{branch_name}") do |io|
        push_lines = io.readlines
        io.each do |line|
          if line.include? "error"
            is_push_success = false 
          end
        end

        io.close
      end

      unless is_push_success
        Logger.error("#{branch_name} push to remote failed!") 
        push_lines.each do |line|
          puts(line)
        end
      end

      is_push_success
    end

    def has_commits(path, branch_name)
      has_commits = false
      IO.popen("cd '#{path}'; git log --branches --not --remotes") do |io|
        io.each do |line|
          has_commits = true if line.include? "commit"
        end

        io.close
      end

      has_commits
    end

    def has_changes(path)
      has_changes = true
      clear_flag = 'nothing to commit, working tree clean'
      IO.popen("cd '#{path}'; git status") do |io|
        io.each do |line|
          has_changes = false if line.include? clear_flag
        end

        io.close
      end

      has_changes
    end

    def discard(path)
      Dir.chdir(path) do
        `git checkout . && git clean -df`
      end
    end

    def del_local(path, branch_name)
      Dir.chdir(path) do
        `git branch -D #{branch_name}`
      end
    end

    def del_remote(path, branch_name)
      Dir.chdir(path) do
        `git push origin --delete #{branch_name}`
      end
    end

    def user
      name = `git config user.name`.chop
      cn_reg = /[\u4e00-\u9fa5]{1}/
      cn_arr = name.scan(cn_reg)
      if cn_arr.count > 0
        Logger.error("git config user.name has Chinese character")
      else
        name.gsub(/[^0-9A-Za-z]/, '').downcase
      end
    end

    def tag(path, version)
      tags = Array.new
      IO.popen("cd '#{path}'; git tag") do |io|
        io.each do |line|
          tags << line
        end

        io.close
      end

      unless tags.include? "#{version}\n"
        Dir.chdir(path) do
          `git tag -a #{version} -m "release: V #{version}" master;`
          `git push --tags`
        end
        return
      end

      Logger.highlight("tag already exists in the remote, skip this step")
    end

    def tag_list(path)
      tag_list = Array.new
      IO.popen("cd '#{path}'; git tag -l --sort=-version:refname") do |io|
        io.each do |line|
          tag_list << line
        end

        io.close
      end

      tag_list
    end

    def check_merge(path, condition)
      unmerged_branch = Array.new
      IO.popen("cd '#{path}'; git branch --no-merged") do |io|
        io.each do |line|
          unmerged_branch.push(line) if line.include? "#{condition}"
        end

        io.close
      end

      if (unmerged_branch.size > 0)
        unmerged_branch.map { |item|
            Logger.default(item)
        }
        Logger.error("Still has unmerged feature branch, please check")
      end
    end

    def fetch(path, branch)
      cmd_line = []

      cmd_line << "cd #{path}"
      cmd_line << "git fetch origin #{branch}"

      IO.popen(cmd_line.join(";")) do |io|
        io.close
      end
    end

    def compare_branch(path, branch, compare_branch)
      diff_commit_list = []

      compare_cmd_list = []
      compare_cmd_list << "cd #{path}"
      compare_cmd_list << "git log --left-right #{branch}...#{compare_branch} --pretty=oneline"

      IO.popen(compare_cmd_list.join(";")) do |io|
        io.each do |line|
          diff_commit_list << line unless line.strip.chomp.empty?
        end

        io.close
      end

      diff_commit_list
    end

    def pull(path, branch, is_merge)
      is_pull_success = true
      has_conflicts = false

      pull_cmd_list = []
      pull_cmd_list << "cd #{path}"
      pull_cmd_list << "git fetch origin #{branch}"

      if is_merge
        pull_cmd_list << "git pull --no-ff --no-squash --no-edit"  
      else
        pull_cmd_list << "git pull --rebase"
      end
      
      pull_io_lines = []
      IO.popen(pull_cmd_list.join(";")) do |io|
        pull_io_lines = io.readlines
        pull_io_lines.each do |line|
          has_conflicts = true if line.include? "Merge conflict"
        end

        io.close
      end

      if has_conflicts
        if is_merge
          Logger.error("【#{path}】\n on branch: \"#{branch}\" (pull)Merge conflict, please manual fix conflicts.(fix conflicts and run \"git commit\")(use \"git merge --abort\" to abort the merge)")
        else
          Logger.error("【#{path}】\n on branch: \"#{branch}\" (pull)Rebase conflict, please manual fix conflicts.(fix conflicts and run \"git rebase --continue\")(use \"git rebase --abort\" to abort the merge)")
        end
        
        is_pull_success = false
      end

      is_pull_success

    end

    def merge(path, parent_branch, son_branch)
      is_merge_success = true

      merge_cmd_list = []
      merge_cmd_list << "cd #{path}"
      merge_cmd_list << "git checkout #{parent_branch}"
      merge_cmd_list << "git fetch origin #{parent_branch}"
      merge_cmd_list << "git reset --hard origin/#{parent_branch}"
      merge_cmd_list << "git merge #{son_branch} --no-ff --no-squash --no-edit"

      merge_cmd_lines = []
      has_conflicts = false
      IO.popen(merge_cmd_list.join(";")) do |io|
        merge_cmd_lines = io.readlines
        merge_cmd_lines.each do |line|
          has_conflicts = true if line.include? "Merge conflict"
        end

        io.close
      end

      if has_conflicts
        Logger.error("branch: \"#{parent_branch}\" Merge conflict, please manual fix conflicts.(fix conflicts and run \"git commit\")(use \"git merge --abort\" to abort the merge)")
        is_merge_success = false
        return is_merge_success
      end

      is_merge_success
    end

    def rebase(path, branch)
      is_rebase_success = true

      is_remote_branch = has_remote_branch(path, branch)

      rebase_cmd_list = []
      rebase_cmd_list << "cd #{path}"

      if is_remote_branch
        rebase_cmd_list << "git fetch origin #{branch}"
        rebase_cmd_list << "git rebase origin/#{branch}"  
      else
        rebase_cmd_list << "git rebase #{branch}"  
      end
      
      has_conflicts = false
      rebase_cmd_lines = []
      IO.popen(rebase_cmd_list.join(";")) do |io|
        rebase_cmd_lines = io.readlines
        rebase_cmd_lines.each do |line|
          has_conflicts = true if line.include? "Merge conflict"
        end

        io.close
      end

      if has_conflicts
        c_branch = current_branch(path)
        Logger.error("【#{path}】\n on branch: \"#{c_branch}\" Merge conflict, please manual fix conflicts.(fix conflicts and run \"git rebase --continue\")(use \"git rebase --abort\" to abort the merge)")
        is_rebase_success = false
      end

      is_rebase_success
    end

    def has_diverged(path)
      has_div = false
      IO.popen("cd #{path};git status") do |io|
        rebase_cmd_lines = io.readlines
        rebase_cmd_lines.each do |line|
          has_div = true if line.include? "diverged"
        end

        io.close
      end
      
      has_div
    end

    #Class end
  end

end
