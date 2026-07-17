class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.2.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.2.0/vibrai-1.2.0-osx-arm64-cli.tar.gz"
      sha256 "fc60bd9d174c40730b7728289388ea3899cc68f6994cf07838a0ab6f9b1cfc33"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.2.0/vibrai-1.2.0-osx-x64-cli.tar.gz"
      sha256 "5925cb8527dd7e91663c6fc6eb55ae3582305387b045a02d0a07f1566a47c6a5"
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
