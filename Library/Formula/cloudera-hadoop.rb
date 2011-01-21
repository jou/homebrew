require 'formula'

class ClouderaHadoop < Formula
  url 'http://archive.cloudera.com/cdh/3/hadoop-0.20.2+737.tar.gz'
  version '0.20.2+737'
  homepage 'http://www.cloudera.com/hadoop/'
  md5 '58fda622140205b3d6a2457415d301f2'

  def shim_script target
    <<-EOS.undent
    #!/bin/bash
    export HADOOP_CONF_DIR="#{etc+'cloudera-hadoop'}"
    export HADOOP_LOG_DIR="#{var+'log/cloudera-hadoop'}"
    exec #{libexec}/bin/#{target} $*
    EOS
  end

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin contrib lib webapps]
    libexec.install Dir['*.jar']
    bin.mkpath
    (var+'run/cloudera-hadoop/tmp').mkpath
    (var+'run/cloudera-hadoop/dfs/name').mkpath
    (var+'log/cloudera-hadoop').mkpath

    unless (etc+'cloudera-hadoop').exist?
      (etc+'cloudera-hadoop').mkpath
      # (etc+'hadoop').install Dir['conf/*']
      (etc+'cloudera-hadoop').install Dir['example-confs/conf.pseudo/*']

      inreplace (etc+'cloudera-hadoop/core-site.xml'), '<value>/var/lib/hadoop-0.20/cache/${user.name}</value>',
        "<value>#{var+'run/cloudera-hadoop/tmp'}</value>"
      inreplace (etc+'cloudera-hadoop/hdfs-site.xml'), '<value>/var/lib/hadoop-0.20/cache/hadoop/dfs/name</value>',
        "<value>#{var+'run/cloudera-hadoop/dfs/name'}</value>"
      %w(masters slaves).each do |f|
        (etc+'cloudera-hadoop'+f).write 'localhost'
      end
    end

    Dir["#{libexec}/bin/*"].each do |b|
      n = Pathname.new(b).basename
      target = n.to_s.match(/^hadoop/) ? n : "hadoop-#{n}"
      (bin+target).write shim_script(n)
    end
  end

  def caveats
    <<-EOS.undent
      $JAVA_HOME must be set for Hadoop commands to work.

      If you installed Hadoop for the first time, you need to format the namenode
      first with `hadoop namenode -format`. Confirm with capital 'Y' (yes, 
      case matters).

      Hadoop is configured in pseude-distributed mode. You need SSH daemon running
      and public key authentication to your local box.

      Start all Hadoop services with `hadoop-start-all.sh`.
    EOS
  end
end
