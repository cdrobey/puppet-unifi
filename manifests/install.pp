class unifi::install (
  Boolean $manage_repository = true,
){
  if $::unifi::manage_repository {
    case $facts['os']['family'] {
      'redhat': {
        package {'java-1.8.0-openjdk-headless':
          ensure   => present,
          provider => yum,
        }
        package {'epel-release':
          ensure => present,
        }
        package { 'mongodb-server':
          ensure  => present,
          require => Package['epel-release'],
        }

        package { 'unifi-controller-5.8.24-1.el7.x86_64.rpm':
          ensure   => present,
          provider => rpm,
          source   => 'http://dl.marmotte.net/rpms/redhat/el7/x86_64/unifi-controller-5.8.24-1.el7/unifi-controller-5.8.24-1.el7.x86_64.rpm',
          require  => Package['java-1.8.0-openjdk-headless', 'mongodb-server'],
        }
      }
      default: {
        apt::key { 'unifi':
          id     => $::unifi::repo_key_id,
          server => $::unifi::repo_key_server,
        }

        apt::source { 'unifi':
          comment  => 'Ubiquiti UniFi Controller APT Repository',
          location => $::unifi::repo_location,
          release  => $::unifi::repo_release,
          require  => Apt::Key['unifi'],
          repos    => 'ubiquiti',
          pin      => '200',
          include  => {
            src => false,
            deb => true,
          },
        }
        package { $::unifi::package_name:
          ensure  => $::unifi::package_ensure,
          require => Apt::Source['unifi'],
        }
      }
    }
  }
}
