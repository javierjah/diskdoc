class Diskdoc < Formula
  desc "macOS disk cleanup CLI — find and remove hidden space hogs"
  homepage "https://github.com/javierjah/diskdoc"
  url "https://github.com/javierjah/diskdoc/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "" # Fill after release: shasum -a 256 v2.0.0.tar.gz
  license "MIT"

  def install
    bin.install "bin/diskdoc"
  end

  test do
    assert_match "diskdoc 2.0.0", shell_output("#{bin}/diskdoc --version")
  end
end
