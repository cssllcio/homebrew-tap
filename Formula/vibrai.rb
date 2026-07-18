class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.3.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.1/vibrai-1.3.1-osx-arm64-cli.tar.gz"
      sha256 "375179d65ad10311f212038d07d8457bafdc95b59b8fb388294d478b9e268308"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.1/vibrai-1.3.1-osx-x64-cli.tar.gz"
      sha256 "ddee46ead0450c26baa37f7473c18a14ebf3749a171743aba0d52aa40cacd685"
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
