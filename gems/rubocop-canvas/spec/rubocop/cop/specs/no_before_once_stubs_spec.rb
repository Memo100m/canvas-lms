# frozen_string_literal: true

#
# Copyright (C) 2016 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

describe RuboCop::Cop::Specs::NoBeforeOnceStubs do
  subject(:cop) { described_class.new }

  context "before(:all)" do
    it "allows all kinds of stubs" do
      offenses = inspect_source(%{
        before(:all) do
          stub_file_data
          stub_kaltura
          stub_png_data
          collection = mock()
          collection.stubs(:table_name).returns("courses")
        end
      })
      expect(offenses.size).to eq(0)
    end
  end

  context "before(:each)" do
    it "allows all kinds of stubs" do
      offenses = inspect_source(%{
        before(:each) do
          stub_file_data
          stub_kaltura
          stub_png_data
          collection = mock()
          collection.stubs(:table_name).returns("courses")
        end
      })
      expect(offenses.size).to eq(0)
    end
  end

  context "before(:once)" do
    it "disallows all kinds of stubs" do
      offenses = inspect_source(%{
        before(:once) do
          stub_file_data
          stub_kaltura
          stub_png_data
          collection = mock()
          collection.stubs(:table_name).returns("courses")
        end
      })
      expect(offenses.size).to eq(5)
      expect(offenses.map(&:message).all? { |msg| msg.include?("`before(:once)`") }).to be true
      expect(offenses.all? { |off| off.severity.name == :warning }).to be true
    end
  end
end
