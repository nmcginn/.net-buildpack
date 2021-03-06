# Encoding: utf-8
# Cloud Foundry NET Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'fileutils'
require 'net_buildpack/container/console'

module NETBuildpack::Container

  describe Console do

    it 'should detect when .exe.config exists' do
      detected = Console.new(
        app_dir: 'spec/fixtures/integration_valid'
      ).detect

      expect(detected).to eq('console')
    end

    it 'should release correct run command in startup script' do
      Dir.mktmpdir do |root|
        lib_directory = File.join(root, '.lib')
        Dir.mkdir lib_directory

        start_script = { :init => [], :run => "" }

        Console.new(
          app_dir: 'spec/fixtures/integration_valid',
          configuration: { :arguments => '' },
          runtime_command: '/path/to/mono',
          :start_script => start_script,
        ).release

        expect(start_script[:run]).to eq('/path/to/mono z-Start.exe')
      end
    end

    it '[on compile] should raise an exception zero .exe.configs are found' do
      Dir.mktmpdir do |root|

        expect {
          Console.new(
              app_dir: root
          ).compile
        }.to raise_error ConsoleExeNotFoundError
        
      end
    end

    it '[on compile] should raise an exception if more than one .exe.config is found' do
      Dir.mktmpdir do |root|
        create_exe_config File.join(root, 'one.exe.config')
        create_exe_config File.join(root, 'two.exe.config')

        expect {
          Console.new(
              app_dir: root
          ).compile
        }.to raise_error ConsoleFoundTooManyExeError
        
      end
    end

    def create_exe_config(filename)
      File.open(filename, 'w') { |f| f.write("<!-- stub .exe.config file -->")}
    end

  end

end