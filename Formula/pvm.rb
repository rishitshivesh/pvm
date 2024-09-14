class Pvm < Formula
  desc "POSIX-compliant Python version manager"
  homepage "https://github.com/youruser/pvm"
  url "https://github.com/youruser/pvm/archive/v0.1.0.tar.gz"
  sha256 "your_generated_sha256_checksum_of_tar_file"
  license "MIT"

  def install
    bin.install "scripts/pvm.sh"
  end

  test do
    assert_match "usage", shell_output("#{bin}/pvm.sh", 2)
  end
end
