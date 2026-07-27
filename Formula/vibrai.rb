class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.3.4"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.4/vibrai-1.3.4-osx-arm64-cli.tar.gz"
      sha256 "49f4dc1fec20f47562eddc12df8aa60695e62527d02fbbdb40607a1540e46f31"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.4/vibrai-1.3.4-osx-x64-cli.tar.gz"
      sha256 "9157ddb931e131e36c63d1c53665dbc5cecb8dde655f6044e2067766aff042de"
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
