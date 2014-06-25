### Global setttings
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { "system-update":
	command => "zypper update -y",
	onlyif => "test $(facter uptime_seconds) -lt 300",
}

package { "wget":
	ensure  => present,
}

package { "apache2":
	ensure  => present,
	require => Exec["system-update"],
}

package { "apache2-mod_php5":
	ensure  => present,
	require => Exec["system-update"],
}

package { "php5-mysql":
	ensure  => latest,
	require => Exec["system-update"],
}

service { "apache2":
	ensure  => "running",
	enable => "true",
	require => Package["apache2"],
}

$install_dir = '/srv/www/htdocs/wp'

file { "${install_dir}":
	ensure  => directory,
	recurse => true,
}

file { "${install_dir}/wp-config-sample.php":
	ensure => present,
}

exec { 'Download wordpress':
	command => "wget http://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz",
	creates => "/tmp/wp.tar.gz",
	require => [ File["${install_dir}"], Package["wget"] ],
} -> 
exec { 'Extract wordpress':
	command => "sudo tar zxvf /tmp/wp.tar.gz --strip-components=1 -C ${install_dir}",
	creates => "${install_dir}/index.php",
	require => Exec["Download wordpress"],
} -> 
exec { "copy_def_config":
	command => "/usr/bin/cp ${install_dir}/wp-config-sample.php ${install_dir}/wp-config.php",
	creates => "${install_dir}/wp-config.php",
	require => File["${install_dir}/wp-config-sample.php"],
} ->
file_line { 'db_name_line':
  path  => "${install_dir}/wp-config.php",
  line  => "define('DB_NAME', 'wordpress_db');",
  match => "^define\\('DB_NAME*",
} ->
file_line { 'db_user_line':
  path  => "${install_dir}/wp-config.php",
  line  => "define('DB_USER', 'wordpress_user');",
  match => "^define\\('DB_USER*",
} ->
file_line { 'db_password_line':
  path  => "${install_dir}/wp-config.php",
  line  => "define('DB_PASSWORD', 'wordpress');",
  match => "^define\\('DB_PASSWORD*",
} ->
file_line { 'db_host_line':
  path  => "${install_dir}/wp-config.php",
  line  => "define('DB_HOST', '192.168.33.3');",
  match => "^define\\('DB_HOST*",
} ~>
exec { 'Change ownership':
	command     => "sudo chown -R wwwrun:www ${install_dir}",
	require => Exec["Extract wordpress"],
	refreshonly => true,
}

exec { "enable-php-module":
	command => "sudo a2enmod php5",
	unless => "grep php5 /etc/sysconfig/apache2",
	require => Package["apache2-mod_php5"],
	notify => Service["apache2"],
}
