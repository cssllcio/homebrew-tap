class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.4.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.4.0/vibrai-1.4.0-osx-arm64-cli.tar.gz"
      sha256 "9fc5ce173e4486e94d7e0e20a1411b8239d9ccaf624425fb5d30c58b17ca9c83"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.4.0/vibrai-1.4.0-osx-x64-cli.tar.gz"
      sha256 "98a19d4acc94b90ebd9a8a8c4a0611a156a9932b3e3dda0d73b52aabac815aae"
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
