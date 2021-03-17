# require File.expand_path('../../lib/podsorz/core/PodsOrz/pods_git_manager', __FILE__)
filep = __FILE__
string = File.expand_path('../spec_helper', __FILE__)
require "#{string}"
require "autopods/core/pods_check_merge"

require 'rspec'

module AutoPods
  describe 'PodsCheckMerge' do
      it 'test autopods  command' do
        # command = Command.parse(%w{ package DZNEmptyDataSet.podspec --exclude-deps --no-mangle --force --embedded --spec-sources=git@gitlab.91banban.com:ios_pods/Specs.git })
        # command.run
        # true.should == true  # To make the test pass without any shoulds
      end
      
      dir_path = File.dirname(__FILE__) 
      path = File.expand_path("../", dir_path)

      # dir_path = "/Users/yuyutao/Desktop/rubyGem/PodsOrz/spec"
      kx_pods_path = File.expand_path("../../kx_pods", dir_path)
			checkManger = AutoPods::PodsCheckMerge.new()
      checkManger.branchList(kx_pods_path)
  end
end