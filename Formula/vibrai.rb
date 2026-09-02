class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://downloads.vibrai.com/v1.7.1/vibrai-1.7.1-osx-arm64-cli.tar.gz"
      sha256 "887a79194bf82af726dd55012713745e9af3c2ca35a41d9ef8960ce210c8ca56"
    end
    on_intel do
      url "https://downloads.vibrai.com/v1.7.1/vibrai-1.7.1-osx-x64-cli.tar.gz"
      sha256 "8ad6df228f3473dc1ded5f8a424f61871248100a0159a25a58b9c2e1d4606a22"
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
