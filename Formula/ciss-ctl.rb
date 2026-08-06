# frozen_string_literal: true

# ciss-ctl — the reference client CLI for CISS (Croft Item Storage Server).
#
#   brew install croftcommunity/tap/ciss-ctl          # the pinned release
#   brew install --HEAD croftcommunity/tap/ciss-ctl   # latest main
class CissCtl < Formula
  desc "Client CLI for CISS: metered S3 + atproto blob planes with gated reads"
  homepage "https://github.com/CroftCommunity/CISS"
  url "https://github.com/CroftCommunity/CISS/releases/download/v0.5.4/ciss-0.5.4.tar.gz"
  sha256 "41c3dd58967c09fa8fc7afee7054608c733b62eff90a6bade2c0fad724bf4c40"
  license "AGPL-3.0-only"
  head "https://github.com/CroftCommunity/CISS.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Build only the client binary from the workspace member. Pure-Rust deps
    # (rustls, k256, ed25519-dalek, ssh-key) — no C toolchain needed.
    system "cargo", "install", *std_cargo_args(path: "crates/ciss-cli")

    # Man page, generated from the built binary's hidden `man` subcommand.
    (buildpath/"ciss-ctl.1").write Utils.safe_popen_read(bin/"ciss-ctl", "man")
    man1.install "ciss-ctl.1"
  end

  test do
    assert_match "ciss-ctl", shell_output("#{bin}/ciss-ctl --version")

    # Generate an identity in an isolated config dir and confirm whoami agrees.
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    did = shell_output("#{bin}/ciss-ctl key gen").strip
    assert_match(/\Aid:[0-9a-f]{64}\Z/, did)
    assert_equal did, shell_output("#{bin}/ciss-ctl whoami").strip
  end
end
