# -*- encoding : utf-8 -*-
#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter/root_home'

describe Facter::Util::RootHome do
  context "solaris" do
    let(:root_ent) { "root:x:0:0:Super-User:/:/sbin/sh" }
    let(:expected_root_home) { "/" }

    it "should return /" do
      Facter::Util::Resolution.expects(:exec).with("getent passwd root").returns(root_ent)
      expect(Facter::Util::RootHome.get_root_home).to eq(expected_root_home)
    end
  end
  context "linux" do
    let(:root_ent) { "root:x:0:0:root:/root:/bin/bash" }
    let(:expected_root_home) { "/root" }

    it "should return /root" do
      Facter::Util::Resolution.expects(:exec).with("getent passwd root").returns(root_ent)
      expect(Facter::Util::RootHome.get_root_home).to eq(expected_root_home)
    end
  end
  context "windows" do
    before :each do
      Facter::Util::Resolution.expects(:exec).with("getent passwd root").returns(nil)
    end
    it "should be nil on windows" do
      expect(Facter::Util::RootHome.get_root_home).to be_nil
    end
  end
end

describe 'root_home', :type => :fact do
  before { Facter.clear }
  after { Facter.clear }

  context "macosx" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      Facter.fact(:osfamily).stubs(:value).returns("Darwin")
    end
    let(:expected_root_home) { "/var/root" }
    sample_dscacheutil = File.read(fixtures('dscacheutil','root'))

    it "should return /var/root" do
      Facter::Util::Resolution.stubs(:exec).with("dscacheutil -q user -a name root").returns(sample_dscacheutil)
      expect(Facter.fact(:root_home).value).to eq(expected_root_home)
    end
  end

  context "aix" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("AIX")
      Facter.fact(:osfamily).stubs(:value).returns("AIX")
    end
    let(:expected_root_home) { "/root" }
    sample_lsuser = File.read(fixtures('lsuser','root'))

    it "should return /root" do
      Facter::Util::Resolution.stubs(:exec).with("lsuser -c -a home root").returns(sample_lsuser)
      expect(Facter.fact(:root_home).value).to eq(expected_root_home)
    end
  end
end
