require 'colorize'

module Logger
	  def self.default(sentence)
      puts format_output(sentence).colorize(:default)
    end

    def self.highlight(sentence)
      puts("\n")
      puts format_output("✅  " + sentence + "\n").colorize(:green)
    end

    def self.error(sentence)
      puts("\n")
      puts format_output("❌  " + sentence + "\n").colorize(:red)
    end

    def self.warning(sentence)
      puts("\n")
      puts format_output("⚠️  " + sentence + "\n").colorize(:yellow)
    end

    def self.separator
      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - -".colorize(:light_blue)
    end

    def self.format_output(sentence)
      "orz: ".concat(sentence.to_s).to_s
    end
	
	
end
