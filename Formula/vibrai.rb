class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.1/vibrai-1.6.1-osx-arm64-cli.tar.gz"
      sha256 "6e90da81d495a27a304ccb743974c482946e469503c3e478c038529d7b4d9252"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.1/vibrai-1.6.1-osx-x64-cli.tar.gz"
      sha256 "bbf45a0f306beaa3a6efa09fa5a910a3bbaeb6bd801cc5a70376edf07795e889"
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
