require 'test_helper'

class FileSystemUnitTest < Minitest::Test
  include Solid

  def test_default
    assert_raises(FileSystemError) do
      BlankFileSystem.new.read_template_file("dummy")
    end
  end

  def test_local
    file_system = Solid::LocalFileSystem.new("/some/path")
    assert_equal "/some/path/_mypartial.solid", file_system.full_path("mypartial")
    assert_equal "/some/path/dir/_mypartial.solid", file_system.full_path("dir/mypartial")

    assert_raises(FileSystemError) do
      file_system.full_path("../dir/mypartial")
    end

    assert_raises(FileSystemError) do
      file_system.full_path("/dir/../../dir/mypartial")
    end

    assert_raises(FileSystemError) do
      file_system.full_path("/etc/passwd")
    end
  end

  def test_custom_template_filename_patterns
    file_system = Solid::LocalFileSystem.new("/some/path", "%s.html")
    assert_equal "/some/path/mypartial.html", file_system.full_path("mypartial")
    assert_equal "/some/path/dir/mypartial.html", file_system.full_path("dir/mypartial")
  end
end # FileSystemTest
