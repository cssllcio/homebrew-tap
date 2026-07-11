class Typeclip < Formula
  desc "Types your clipboard with human cadence - built for screen recordings"
  homepage "https://github.com/cssllcio/typeclip"
  url "https://github.com/cssllcio/typeclip/releases/download/v0.1.0/typeclip-v0.1.0-macos-universal.zip"
  sha256 "cd3ee49fdd96faf121f0e4c2b7da3295c4a4c0aa1c31f06a7ce9208979c2d019"
  version "0.1.0"

  def install
    bin.install "typeclip"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/typeclip --version")
  end
end
