require 'spec_helper'
describe 'mailhog' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults for all parameters' do
        it { should contain_class('mailhog') }
        it { should contain_anchor('mailhog::begin').that_comes_before('Class[mailhog::Install]') }
        it { should contain_class('mailhog::install').that_comes_before('Class[mailhog::Config]') }
        it { should contain_class('mailhog::config').that_notifies('Class[mailhog::Service]') }
        it { should contain_class('mailhog::service').that_comes_before('Anchor[mailhog::end]') }
        it { should contain_anchor('mailhog::end') }
        it { should contain_package('mailhog') }
        it { should contain_service('mailhog') }
      end

      context 'with wget_source set to special_mailhog' do
        let(:params) {
          {
            :install_method => 'wget',
            :wget_source    => 'special_mailhog',
          }
        }
        it { should contain_wget__fetch('/usr/bin/mailhog').with_source('special_mailhog') }
      end

      context 'with install_dir set to /opt/special' do
        let(:params) {
          {
              :install_dir    => '/opt/special',
              :install_method => 'wget'
          }
        }
        it { should contain_file('/opt/special')}
        it { should contain_wget__fetch('/usr/bin/mailhog').with_destination('/opt/special/mailhog') }
        it { should contain_wget__fetch('/usr/bin/mailhog').that_requires('File[/opt/special]') }
      end

      context 'with install_dir set to /opt/special and manage_service set to true and service_provider set to debian' do
        let(:params) {
          {
              :install_dir      => '/opt/special',
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'debian'
          }
        }
        it { should contain_file('/etc/init.d/mailhog').with_content(/(^exec="\/opt\/special\/mailhog"$)+/) }
      end

      context 'with install_dir set to /opt/special and manage_service set to true and service_provider set to init' do
        let(:params) {
          {
              :install_dir      => '/opt/special',
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'init'
          }
        }
        it { should contain_file('/etc/init.d/mailhog').with_content(/(^exec="\/opt\/special\/mailhog"$)+/) }
      end

      context 'with install_dir set to /opt/special and manage_service set to true and service_provider set to redhat' do
        let(:params) {
          {
              :install_dir      => '/opt/special',
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'redhat'
          }
        }
        it { should contain_file('/etc/init.d/mailhog').with_content(/(^exec="\/opt\/special\/mailhog"$)+/) }
      end

      context 'with install_dir set to /opt/special and manage_service set to true and service_provider set to systemd' do
        let(:params) {
          {
              :install_dir      => '/opt/special',
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'systemd'
          }
        }
        it { should contain_systemd__Unit_file('mailhog.service').with_content(/(\/opt\/special\/mailhog.*$)+/) }
      end

      context 'with install_method set to package' do
        let(:params) {
          {
              :install_dir    => '/usr/bin',
              :install_method => 'package',
              :package_name   => 'mailhog'
          }
        }
        it { should_not contain_file('/usr/bin').that_comes_before('Wget::Fetch[/usr/bin/mailhog]') }
        it { should_not contain_wget__fetch('/usr/bin/mailhog') }
        it { should contain_package('mailhog') }
      end

      context 'with install_method set to wget' do
        let(:params) {
          {
              :install_dir    => '/usr/bin',
              :install_method => 'wget',
              :package_name   => 'mailhog'
          }
        }
        it { should contain_file('/usr/bin').that_comes_before('Wget::Fetch[/usr/bin/mailhog]') }
        it { should contain_wget__fetch('/usr/bin/mailhog') }
        it { should_not contain_package('mailhog') }
      end

      context 'with install_method set to invalid' do
        let(:params) {
          {
              :install_method => 'invalid'
          }
        }
        it { should raise_error(/Installation method invalid not supported/) }
      end

      context 'with manage_service set to true' do
        let(:params) {
          {
              :manage_service => true,
              :service_name   => 'mailhog'
          }
        }
        it { should contain_service('mailhog') }
      end

      context 'with manage_service set to false' do
        let(:params) {
          {
              :manage_service => false,
              :service_name   => 'mailhog'
          }
        }
        it { should_not contain_service('mailhog') }
      end

      context 'with package_name set to specialpackage' do
        let(:params) {
          {
              :install_method => 'package',
              :package_name   => 'specialpackage',
          }
        }
        it { should contain_package('specialpackage') }
      end

      context 'with package_name set to specialpackage and manage_service set to true' do
        let(:params) {
          {
              :install_method => 'package',
              :manage_service => true,
              :package_name   => 'specialpackage',
              :service_name   => 'mailhog'
          }
        }
        it { should contain_package('specialpackage') }
        it { should contain_service('mailhog').that_subscribes_to('Package[specialpackage]') }
      end

      context 'with package_version set to 42.42.42' do
        let(:params) {
          {
              :install_method  => 'package',
              :package_name    => 'mailhog',
              :package_version => '42.42.42',
          }
        }
        it { should contain_package('mailhog').with_ensure('42.42.42') }
      end

      context 'with service_name set to specialservice' do
        let(:params) {
          {
              :manage_service => true,
              :service_name   => 'specialservice',
          }
        }
        it { should contain_service('specialservice') }
      end

      context 'with service_name set to specialservice and with service_provider set to debian' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'specialservice',
              :service_provider => 'debian',
          }
        }
        it { should contain_service('specialservice') }
        it { should contain_file('/etc/init.d/specialservice').that_notifies('Service[specialservice]').with_content(/^prog="specialservice"/) }
      end

      context 'with service_name set to specialservice and with service_provider set to init' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'specialservice',
              :service_provider => 'init',
          }
        }
        it { should contain_service('specialservice') }
        it { should contain_file('/etc/init.d/specialservice').that_notifies('Service[specialservice]').with_content(/^prog="specialservice"/) }
      end

      context 'with service_name set to specialservice and with service_provider set to redhat' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'specialservice',
              :service_provider => 'redhat',
          }
        }
        it { should contain_service('specialservice') }
        it { should contain_file('/etc/init.d/specialservice').that_notifies('Service[specialservice]').with_content(/^prog="specialservice"/) }
      end

      context 'with service_name set to specialservice and with service_provider set to systemd' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'specialservice',
              :service_provider => 'systemd',
          }
        }
        it { should contain_service('specialservice') }
        it { should contain_systemd__Unit_file('specialservice.service').that_comes_before('Service[specialservice]').with_content(/^Description=specialservice/) }
      end

      context 'with service_name set to specialservice and with install_method set to package' do
        let(:params) {
          {
              :install_method => 'package',
              :manage_service => true,
              :package_name   => 'mailhog',
              :service_name   => 'specialservice',
          }
        }
        it { should contain_service('specialservice').that_subscribes_to('Package[mailhog]') }
      end

      context 'with service_provider set to init' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'init',
          }
        }
        it { should contain_file('/etc/init.d/mailhog') }
        it { should_not contain_systemd__Unit_file('mailhog.service').that_comes_before('Service[mailhog]') }
        it { should contain_service('mailhog') }
      end

      context 'with service_provider set to systemd' do
        let(:params) {
          {
              :manage_service   => true,
              :service_name     => 'mailhog',
              :service_provider => 'systemd',
          }
        }
        it { should_not contain_file('/etc/init.d/mailhog') }
        it { should contain_systemd__Unit_file('mailhog.service').that_comes_before('Service[mailhog]') }
        it { should contain_service('mailhog') }
      end

      context 'with service_provider set to invalid' do
        let(:params) {
          {
              :manage_service   => true,
              :service_provider => 'invalid',
          }
        }
        it { should raise_error(/Service provider invalid not supported/) }
      end
    end
  end
end
