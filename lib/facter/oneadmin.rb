# $Id: oneadmin.rb 4200 2011-04-12 13:21:53Z uwaechte $
#
# fact to show the admin user
require 'etc'

begin
  adm = %x{groups oneadmin 2>/dev/null|cut -f 3- -d' '}.chomp 
rescue 
  exit 0
end

if adm != ""
  #out = "#{adm.name} (uid=#{adm.uid},gid=#{adm.gid},gecos=#{adm.gecos},home=#{adm.dir})"
  Facter.add("user_oneadmin_groups") do
    setcode do
      adm.split(" ").sort.join(" ")
    end
  end
end

