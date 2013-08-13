import "system-packages.pp"
import "mongo.pp"
import "redis.pp"

$install_dir = '/home/vagrant'

file { '/home/vagrant/.screenrc':
   ensure => 'link',
   target => '/vagrant/.screenrc',
}

exec { "load-screen":
    cwd => "$install_dir",
    command => '/usr/bin/screen -AmdS clj -t appjs bash',
    user => 'vagrant',
    unless => "/usr/bin/test `screen -list | grep skunks | wc -l` '-gt' 0",
    require => [
        File['/home/vagrant/.screenrc'],
        Package['screen'],
        #Exec['info-sequences-checkout'],
    ],
}

exec { "run-app":
    cwd => "$install_dir",
    command => "/usr/bin/screen -S skunks -p appjs -X stuff \'sudo node app.js\r\'",
    user => 'vagrant',
    require => [
        Exec['load-screen'],
        Package['g++'],
    ],
}