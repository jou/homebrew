require 'formula'

class Zookeeper <Formula
  url 'http://mirror.switch.ch/mirror/apache/dist/hadoop/zookeeper/zookeeper-3.3.1/zookeeper-3.3.1.tar.gz'
  homepage 'http://hadoop.apache.org/zookeeper'
  md5 'bdcd73634e3f6623a025854f853c3d0d'

  def shim_script target
    <<-EOS.undent
      #!/usr/bin/env bash
      . #{zk_etc+'defaults'}
      export ZOOCFGDIR
      cd #{libexec}/bin
      ./#{target} $*
    EOS
  end

  def default_zk_env
    <<-EOS
      ZOOCFGDIR="#{zk_etc}"
    EOS
  end

  def default_log4j_properties
    <<-EOS
      log4j.rootCategory=WARN, zklog

      log4j.appender.zklog = org.apache.log4j.FileAppender
      log4j.appender.zklog.File = #{zk_log_dir+'zookeeper.log'}
      log4j.appender.zklog.Append = true
      log4j.appender.zklog.layout = org.apache.log4j.PatternLayout
      log4j.appender.zklog.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss} %c{1} [%p] %m%n
    EOS
  end

  def zk_etc
    etc+'zookeeper'
  end

  def zk_log_dir
    var+'log'+'zookeeper'
  end

  def zk_data_dir
    var+'run'+'zookeeper'+'data'
  end


  def install
    # Remove windows executables
    rm_f Dir["bin/*.cmd"]

    # Install Java stuff
    libexec.install %w(bin contrib lib)
    libexec.install Dir['*.jar']

    # Create neccessary directories
    bin.mkpath
    zk_etc.mkpath
    zk_log_dir.mkpath
    zk_data_dir.mkpath

    # Install shim scripts to bin
    bin_excludes = %w(README.txt zkEnv.sh)
    Dir["#{libexec}/bin/*"].map { |path| 
      Pathname.new path
    }.reject { |path| 
      bin_excludes.include? path.basename.to_s
    }.each { |path|
      script_name = path.basename
      bin_name    = path.basename '.sh'

      (bin+bin_name).write shim_script(script_name)
    }

    # Install default config files
    defaults = zk_etc+'defaults'
    defaults.write(default_zk_env) if !defaults.exist?

    log4j_properties = zk_etc+'log4j.properties'
    log4j_properties.write(default_log4j_properties) if !log4j_properties.exist?

    zoo_cfg = zk_etc+'zoo.cfg'
    if !zoo_cfg.exist?
      inreplace 'conf/zoo_sample.cfg', /^dataDir=.*/, "dataDir=#{zk_data_dir}"
      cp 'conf/zoo_sample.cfg', zoo_cfg
    end
  end
end
