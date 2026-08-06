# frozen_string_literal: true

# ciss-ctl — the reference client CLI for CISS (Croft Item Storage Server).
#
# No tagged CISS release ships `ciss-ctl` yet, so this installs from HEAD:
#
#   brew install --HEAD croftcommunity/tap/ciss-ctl
#
# When a release that includes `ciss-ctl` is cut, add a stable `url` + verified
# `sha256` stanza above `head` and drop the `--HEAD` requirement.
class CissCtl < Formula
  desc "Client CLI for CISS: metered S3 + atproto blob planes with gated reads"
  homepage "https://github.com/CroftCommunity/CISS"
  license "AGPL-3.0-only"
  head "https://github.com/CroftCommunity/CISS.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Build only the client binary from the workspace member. Pure-Rust deps
    # (rustls, k256, ed25519-dalek, ssh-key) — no C toolchain needed.
    system "cargo", "install", *std_cargo_args(path: "crates/ciss-cli")
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
