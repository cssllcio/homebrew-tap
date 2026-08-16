class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.2/vibrai-1.6.2-osx-arm64-cli.tar.gz"
      sha256 "a7dfdecceacf02748b38c6c61f54f7517091efb8523479042457c1105f8c2c11"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.6.2/vibrai-1.6.2-osx-x64-cli.tar.gz"
      sha256 "136ecb7e5a7fc8d5a4261699b035e65da0e5798302f189c210c686ad8f2cd04e"
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

      If you previously used the standalone installer, remove it first:
        vibrai uninstall
      It symlinks into /usr/local/bin, which the default macOS PATH searches
      BEFORE /opt/homebrew/bin — so `vibrai` would keep running the old copy
      and `brew upgrade` would silently update one you never execute (#519).
      `vibrai --version` warns when it detects this.
    CAVEATS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vibrai --version")
  end
end
