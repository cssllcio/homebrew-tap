class Vibrai < Formula
  desc "Vibrai CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  version "1.3.3"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.3/vibrai-1.3.3-osx-arm64-cli.tar.gz"
      sha256 "a1fbe4c4de34c81395db8aff93caec30991effbf6b782fea1ad49b28343edf52"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.3/vibrai-1.3.3-osx-x64-cli.tar.gz"
      sha256 "1c3363dd90c148bcbaa71b8e18a24f400adcadf52f6c668e77099e0dcafb3a36"
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
