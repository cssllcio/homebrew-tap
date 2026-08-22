class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://downloads.vibrai.com/v1.6.5/vibrai-1.6.5-osx-arm64-cli.tar.gz"
      sha256 "5bc202fe78c7bc5ee09c0f43e2c91b354c055e900294fb97cd59b1918b72259f"
    end
    on_intel do
      url "https://downloads.vibrai.com/v1.6.5/vibrai-1.6.5-osx-x64-cli.tar.gz"
      sha256 "831fcad93fdbc89ca254104192d4ebe013537794d1d1f824b9ae82c8defe6365"
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
