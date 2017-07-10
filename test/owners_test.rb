require "owners"
require "minitest/spec"
require "minitest/autorun"

describe Owners do
  describe "for" do
    before do
      @owners = Owners::File.new(<<-EOF)
        foo@example.com
        @owner
        @org/team
        @focused *.md
      EOF

      @comments = Owners::File.new(<<-EOF)
        # README
        @owner1 file1.txt
        # C,O;M"M'E:N@T$
        @owner2 file2.txt
        # @notcorrectowner file3.txt
        @owner3 file3.txt
      EOF
    end

    it "returns all users without a path specified" do
      assert_equal ["foo@example.com", "@owner", "@org/team"], @owners.for("README")
    end

    it "returns users with matching path" do
      assert_equal ["foo@example.com", "@owner", "@org/team", "@focused"], @owners.for("README.md")
    end

    it "returns teams with matching path" do
      assert_equal ["@org/legal"], Owners::File.new("@org/legal LICENSE").for("LICENSE")
    end

    it "returns users matching any path" do
      owners = Owners::File.new("@user *.rb *.py")
      assert_equal ["@user"], owners.for("foo.rb")
      assert_equal ["@user"], owners.for("foo.py")
    end

    it "does not returns users with non-matching path" do
      assert_equal ["foo@example.com", "@owner", "@org/team"], @owners.for("README")
    end

    it "ignores comments and newlines" do
      assert_equal ["@owner1"], @comments.for("file1.txt")
    end

    it "ignores comments containing special characters" do
      assert_equal ["@owner2"], @comments.for("file2.txt")
    end

    it "ignores tokens after comment mark" do
      assert_equal ["@owner3"], @comments.for("file3.txt")
    end

    it "does not accept newlines as whitespace in comments" do
      assert_equal ["@team"], Owners::File.new("#\n@team").for("README") 
    end
  end
end
