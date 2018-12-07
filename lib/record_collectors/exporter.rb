#!/usr/bin/env ruby
 require 'net/ssh'
 require 'shellwords'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  # run the export command on a fedora server for records identified in pid_file
  # then export to local machine ready for metadata extraction
  def export_foxml(host, digilib_pwd, fed_password, pid_file, to_dir)
    ensure_empty_export_dir(host, digilib_pwd)
    puts 'ensured empty /tmp/fedora_exports dir, preparing to export records'
    bindir = '/opt/york/digilib/fedora/client/bin'
    export_dir = '/tmp/fedora_exports'
    feduser = 'fedoraAdmin'
    fedhost = host.shellescape
    digilib_pwd = digilib_pwd.shellescape
    fed_password = fed_password.shellescape
    main_user = 'digilib'
    pidlist = pid_file.shellescape
    Net::SSH.start(fedhost, main_user, :password => digilib_pwd) do|ssh|
      args = "#{feduser} #{fed_password} #{fedhost} #{export_dir} #{pidlist}"
      ssh.exec!("cd #{bindir} && './exportRecordBatch.sh' #{args}")
    end
    exec("sshpass -p #{digilib_pwd} sftp #{main_user}@#{fedhost}:#{export_dir}/*.xml #{to_dir}")
  end

  def ensure_empty_export_dir(host, digilib_pwd)
    host = host.shellescape
    digilib_pwd = digilib_pwd.shellescape
    Net::SSH.start(host, 'digilib', :password => digilib_pwd) do|ssh|
      ssh.exec!("cd /tmp ; rm -r fedora_exports")
      ssh.exec!("cd /tmp ; mkdir fedora_exports")
    end
  end
end
