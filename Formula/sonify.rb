class Sonify < Formula
  desc "365 Strange Attractors sonification pipeline (emits .vibrai compositions)"
  homepage "https://github.com/cssllcio/sonify-releases"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/cssllcio/sonify-releases/releases/download/v0.1.0/sonify-0.1.0-osx-arm64-cli.tar.gz"
      sha256 "8bbd9d090fe572ac37901b696d82e304813cf1ebccac69a954024e740bfad946"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"sonify"
  end

  def caveats
    <<~CAVEATS
      sonify resolves its working files against a workspace: run it from
      inside the Sonification repo, or set SONIFY_HOME to the repo root.

      The audition verb needs the vibrai CLI (brew install cssllcio/tap/vibrai)
      and Ableton Live.

      This install is managed by Homebrew — use `brew upgrade sonify` to
      update.
    CAVEATS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sonify --version")
  end
end
