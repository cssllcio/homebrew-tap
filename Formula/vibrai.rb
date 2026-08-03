class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.5.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.5.0/vibrai-1.5.0-osx-arm64-cli.tar.gz"
      sha256 "a021ccf7db6b981a39ab528045d36de1179d88ca765857f2c692ad1ae0d6f062"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.5.0/vibrai-1.5.0-osx-x64-cli.tar.gz"
      sha256 "30cdb9fc12122c96b7756c9d61c94c153173a83f42a4a27244d560507b979a3f"
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
