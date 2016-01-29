require 'spec_helper'

describe 'couchbase' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
             :concat_basedir => '/foo'
          })
        end

        context "couchbase class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('couchbase::params') }
          it { is_expected.to contain_class('couchbase::install').that_comes_before('couchbase::config') }
          it { is_expected.to contain_class('couchbase::service') }
          it { is_expected.to contain_class('couchbase::config') }
          it { is_expected.to contain_class('couchbase::service').that_comes_before('couchbase::config') }
          it { is_expected.to contain_service('couchbase-server') }
          it { is_expected.to contain_package('couchbase-server').with_ensure('installed') }
          it { is_expected.to contain_file('/opt/couchbase/var/lib/couchbase/data') }
          it { is_expected.to contain_file('/opt/couchbase/var/lib/couchbase/data').that_comes_before(['Service[couchbase-server]'])}

          if facts[:os]["family"] == 'RedHat' && facts[:os]["release"]["major"] == '7'
            it { is_expected.to contain_exec('no_symbolic_link').that_comes_before('Service[couchbase-server]') }
          else
            it { is_expected.to_not contain_exec('no_symbolic_link') }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'couchbase class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('couchbase') }.to raise_error(Puppet::Error, /Unsupported OS: Solaris/) }
    end
  end
end
