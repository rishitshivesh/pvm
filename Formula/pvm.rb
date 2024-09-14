class Pvm < Formula
  desc "POSIX-compliant Python version manager"
  homepage "https://github.com/rishitshivesh/pvm"
  url "https://github.com/rishitshivesh/pvm/archive/v0.1.3.tar.gz"
  sha256 "your_generated_sha256_checksum_of_tar_file"
  license "MIT"

  def install
    bin.install "scripts/pvm.sh"
  end

  test do
    assert_match "usage", shell_output("#{bin}/pvm.sh", 2)
  end
end
