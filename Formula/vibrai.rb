class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.0/vibrai-1.6.0-osx-arm64-cli.tar.gz"
      sha256 "3a0d9d1fb5ca8f891cf5c4e489e8ae8553ad87c485df899bb5f88d1a5928f0b4"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.0/vibrai-1.6.0-osx-x64-cli.tar.gz"
      sha256 "d96fc24bf37f764f43896cbfadec84cd3728e98405a7daf752f2eb67fa129c99"
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
