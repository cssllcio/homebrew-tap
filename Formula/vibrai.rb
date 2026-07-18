class Vibrai < Formula
  desc "CLI + MCP server for Ableton Live"
  homepage "https://vibrai.com"
  # Proprietary, all rights reserved — Homebrew has no SPDX id for this,
  # :cannot_represent is the documented correct value, not a placeholder.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.0/vibrai-1.3.0-osx-arm64-cli.tar.gz"
      sha256 "68f1ba53debe50cfa71fb828cb21e6ff38af6bb3d6832d007b7c1b3965fd8722"
    end
    on_intel do
      url "https://github.com/cssllcio/vibrai-releases/releases/download/v1.3.0/vibrai-1.3.0-osx-x64-cli.tar.gz"
      sha256 "78052cc533b648925912d57276f8edd625a83765017a29dfd94262c80c17374d"
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
