class RedoGenerator < Rails::Generators::Base
  
  def redo
    executed = false
    executed_command = ""
    executed_generator = ""
    executed_action = ""
        
    File.open(File.join(RAILS_ROOT, 'log/undone.log'), 'r+') do |f| 
      zeroes = 0
      f.readlines.reverse.each do |r|
        
        if r.strip == "0"
          zeroes += 1
          next
        end
        
        args = r.split(" ")
        # rails command generator action
        command = args[0]
        generator = args[1]
        action = args[2]
        
        command_long = "#{generator} #{action}"
        
        if generate?(command) and valid_argument?(generator)
          if zeroes > 0
            zeroes -= 1
            next
          end
          
          response = ask "      Do you wish to redo \x1b\x5b33;22;32m#{command_long.strip}\x1b\x5b0;37;40m? [Y/N]\n     "

          if ["y", "yes", "true"].include?(response.downcase)
            executed = true
            executed_command = "#{r}"
            executed_generator = generator
            executed_action = action
          end
        end
        
        break if executed
      end
    end
    
    if executed
      File.open(File.join(RAILS_ROOT, 'log/generate.log'), 'a+') do |f| 
        f.write(executed_command)
      end
      File.open(File.join(RAILS_ROOT, 'log/undone.log'), 'a+') do |f| 
        f.write("0\n")
      end
      exec "rails #{executed_command}"
    end
      
    puts "      Nothing to redo" if !executed
  end
  
  private
  
    def generate? command
      command == "g" || command == "generate"
    end
  
    def valid_argument? argument
      argument.index("--").nil?
    end
    
end
