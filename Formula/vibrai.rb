class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.3.2"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.2/vibrai-1.3.2-osx-arm64-cli.tar.gz"
      sha256 "d8e6fd8cb073d2b0b90eaa3e2d61f9b136e5fa5823ae42a71546eb5c91841948"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.2/vibrai-1.3.2-osx-x64-cli.tar.gz"
      sha256 "d6e65a06aa070f0e82101f6ace8f9a21ebebbe75cd23b69f98ae27a593ff83c3"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"vibrai"
  end

  def caveats
    <<~CAVEATS
      Vibrai's MCP server for Claude Desktop lives at:
        #{opt_libexec}/Vibrai.Mcp

      To wire up Ableton Live (Max for Live device, Remote Script):
        vibrai install all

      This install is managed by Homebrew — use `brew upgrade vibrai` to
      update, not `vibrai update` (which refuses on a Homebrew-managed
      install).
    CAVEATS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vibrai --version")
  end
end
