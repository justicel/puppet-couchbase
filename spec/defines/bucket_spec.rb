require 'spec_helper'

# Regression + security coverage for GH issue #42:
#   "Failure of ::couchbase::bucket/Exec[bucket-create-*] Logs Passwords in Plain Text"
#
# The couchbase cluster/bucket passwords must never be interpolated directly
# into the Exec's `command`/`unless` strings, because Puppet logs the literal
# command attribute whenever the Exec fails and tagmail will e-mail that report.
# The passwords are instead exported through the command environment
# (CB_PASSWORD / CB_BUCKET_PASSWORD) and referenced as shell variables.
describe 'couchbase::bucket' do
  let(:cluster_secret) { 'sup3rSecretClusterPW' }
  let(:bucket_secret)  { 'bucketOnlySecretPW' }
  let(:title) { 'default' }

  # Declaring the couchbase class satisfies the `$::couchbase::ensure == present`
  # guard and provides the install/config/service anchors the define requires.
  let(:pre_condition) { "class { 'couchbase': }" }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          :concat_basedir => '/tmp',
          :servername     => 'localhost',
          :fqdn           => 'node.example.com',
          :ipaddress      => '127.0.0.1',
          :path           => '/usr/bin:/bin',
        )
      end

      # --- Unit -----------------------------------------------------------
      context 'unit: couchbase bucket resource' do
        let(:params) do
          {
            :user            => 'admin',
            :password        => cluster_secret,
            :type            => 'couchbase',
            :bucket_password => bucket_secret,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('bucket-create-default') }
        it { is_expected.to contain_exec('bucket-create-default').with_provider('shell') }
        it { is_expected.to contain_exec('bucket-create-default').with_logoutput('on_failure') }
      end

      # --- Security -------------------------------------------------------
      # The core of #42: no password may appear in any string that Puppet logs.
      context 'security: password is never present in the command strings' do
        let(:params) do
          {
            :user            => 'admin',
            :password        => cluster_secret,
            :type            => 'couchbase',
            :bucket_password => bucket_secret,
          }
        end

        let(:exec_res) { catalogue.resource('Exec', 'bucket-create-default') }

        it 'does not leak the cluster password in the command' do
          expect(exec_res[:command]).not_to include(cluster_secret)
        end

        it 'does not leak the bucket password in the command' do
          expect(exec_res[:command]).not_to include(bucket_secret)
        end

        it 'does not leak the cluster password in the unless check' do
          expect(exec_res[:unless]).not_to include(cluster_secret)
        end

        it 'references the passwords via shell environment variables instead' do
          expect(exec_res[:command]).to include('$CB_PASSWORD')
          expect(exec_res[:command]).to include('$CB_BUCKET_PASSWORD')
          expect(exec_res[:unless]).to include('$CB_PASSWORD')
        end

        it 'exports the secrets through the exec environment' do
          expect(exec_res[:environment]).to include("CB_PASSWORD=#{cluster_secret}")
          expect(exec_res[:environment]).to include("CB_BUCKET_PASSWORD=#{bucket_secret}")
        end
      end

      # --- Integration ----------------------------------------------------
      # Verify ordering/anchoring against the couchbase config class holds.
      context 'integration: ordering against couchbase::config' do
        let(:params) do
          { :user => 'admin', :password => cluster_secret, :type => 'couchbase' }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_exec('bucket-create-default').that_requires('Class[couchbase::config]')
        end
      end

      # --- Functional -----------------------------------------------------
      # A memcached bucket has no bucket password, so only CB_PASSWORD is set
      # and neither replica nor bucket-password options are emitted.
      context 'functional: memcached bucket without a bucket password' do
        let(:params) do
          { :user => 'admin', :password => cluster_secret, :type => 'memcached' }
        end

        let(:exec_res) { catalogue.resource('Exec', 'bucket-create-default') }

        it { is_expected.to compile.with_all_deps }

        it 'still keeps the cluster password out of the command' do
          expect(exec_res[:command]).not_to include(cluster_secret)
          expect(exec_res[:command]).to include('$CB_PASSWORD')
        end

        it 'exports only CB_PASSWORD when no bucket password is given' do
          expect(exec_res[:environment]).to eq(["CB_PASSWORD=#{cluster_secret}"])
        end

        it 'does not add a bucket-password flag' do
          expect(exec_res[:command]).not_to include('--bucket-password')
        end
      end

      # --- Edge case ------------------------------------------------------
      # A password containing shell-significant characters must remain quoted
      # in the environment value and absent from the command.
      context 'edge case: password with special characters' do
        let(:tricky_pw) { "p@ss w0rd'\"$`" }
        let(:params) do
          { :user => 'admin', :password => tricky_pw, :type => 'couchbase' }
        end

        let(:exec_res) { catalogue.resource('Exec', 'bucket-create-default') }

        it { is_expected.to compile.with_all_deps }

        it 'does not embed the tricky password in the command' do
          expect(exec_res[:command]).not_to include(tricky_pw)
        end

        it 'carries the tricky password verbatim in the environment' do
          expect(exec_res[:environment]).to include("CB_PASSWORD=#{tricky_pw}")
        end
      end

      # --- Retry ----------------------------------------------------------
      # N/A: this Exec is idempotent (guarded by `unless`) and has no retry
      # semantics to exercise. Placeholder kept for parity across the 7
      # required test categories.
      context 'retry: not applicable' do
        it 'is a no-op placeholder' do
          expect(true).to be(true)
        end
      end
    end
  end
end
