import "system-packages.pp"
import "mongo.pp"
import "redis.pp"

$install_dir = '/home/vagrant'

file { '/home/vagrant/.screenrc':
   ensure => 'link',
   target => '/vagrant/.screenrc',
}

file { '/home/vagrant/bin':
   ensure => 'directory',
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
    command => "/usr/bin/screen -S skunks -p appjs -X stuff \'sudo ls\r\'",
    user => 'vagrant',
    require => [
        Exec['load-screen'],
        Package['g++'],
    ],
}

exec {"wget-lein":
    cwd => "$install_dir/bin",
    require => File['/home/vagrant/bin'],
}

define download_file(
        $site="https://raw.github.com/technomancy/leiningen/stable/bin/lein",
        $cwd="/home/vagrant/bin",
        $creates="/home/vagrant/bin/lein",
        $require="",
        $user="vagrant") {

    exec { $name:
        command => "wget ${site}/${name}",
        cwd => $cwd,
        creates => "${cwd}/${name}",
        require => $require,
        user => $user,
    }
}
