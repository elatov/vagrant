### Global setttings
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { "system-update":
	command => "zypper update -y",
	onlyif => "test $(facter uptime_seconds) -lt 300",
}

package { "mysql-community-server-client":
	ensure  => present,
}

package { "mysql-community-server":
        ensure  => present,
        require => Exec["system-update"],
}

service { "mysql":
	ensure  => "running",
	enable => "true",
	require => Package["mysql-community-server"],
}

$mysql_password = "testing"
$db_name = "wordpress_db"
$db_user = "wordpress_user"
$db_pass = "wordpress"
$db_access = "192.168.33.%"

exec { "set-mysql-password":
    unless => "mysqladmin -u root -p\"$mysql_password\" status",
    command => "mysqladmin -u root password \"$mysql_password\"",
    require => [ Package["mysql-community-server-client"], Service["mysql"] ]
}

exec { "create-wordpress-db":
      unless => "mysql -uroot -p$mysql_password ${db_name}",
      command => "mysql -uroot -p$mysql_password -e \"create database ${db_name}; grant all on ${db_name}.* to ${db_user}@'$db_access' identified by '$db_pass';\"",
      require => [ Package["mysql-community-server-client"], Service["mysql"], Exec["set-mysql-password"] ]
}
