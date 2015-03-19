class Acs::Ldap::Logger < ::Logger

  def self.error(message)
      build.error(message)
    end

    def self.info(message)
      build.info(message)
    end

    def self.debug(message)
      build.debug(message)
    end

    def self.read_latest
      path = Rails.root.join("log", file_name)
      self.build unless File.exist?(path)
      tail_output, _ = Manager::Popen.popen(%W(tail -n 2000 #{path}))
      tail_output.split("\n")
    end

    def self.read_latest_for filename
      path = Rails.root.join("log", filename)
      tail_output, _ = Manager::Popen.popen(%W(tail -n 2000 #{path}))
      tail_output.split("\n")
    end

    def self.build
      new(Rails.root.join("log", file_name))
    end

    def self.file_name
      file_name_noext + '.log'
    end

    def format_message(severity, timestamp, progname, msg)
      "#{severity} : #{timestamp.strftime("%y-%m-%d %H:%M:%S:%L %z")} : #{msg}\n"
    end

    def self.archive
      %x(gzip -c #{file_path} > #{targz_file_path})
    end

    def self.clear
      %x(echo > #{file_path})
    end

    def self.size
      File.new(file_path).size
    end

    def self.targz_file_path
      targz_file_name = "#{file_name}-" + %x(date "+%Y%m%d_%H%M%S").gsub("\n", '') + ".gz"
      Rails.root.join("log", targz_file_name).to_s
    end

    def self.file_path
      if Rails.root.present?
        Rails.root.join("log", file_name).to_s
      else
        [Dir.pwd, "log", file_name].join("/").to_s
      end
    end

    def self.build
      # File.delete(file_path)
      self.new(file_path)
    end


    ##########

    def self.file_name_noext
      "acs_ldap"
    end

    def self.file_name
      file_name_noext + ".log"
    end

end
