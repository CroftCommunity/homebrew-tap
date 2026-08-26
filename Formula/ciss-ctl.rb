# frozen_string_literal: true

# ciss-ctl — the reference client CLI for CISS (Croft Item Storage Server).
#
#   brew install croftcommunity/tap/ciss-ctl          # the pinned release
#   brew install --HEAD croftcommunity/tap/ciss-ctl   # latest main
class CissCtl < Formula
  desc "Client CLI for CISS: metered S3 + atproto blob planes with gated reads"
  homepage "https://github.com/CroftCommunity/CISS"
  # Source tarball. CISS releases stopped publishing a source asset after v0.7.0
  # (v0.8.0+ ship only the prebuilt linux binary), so this uses GitHub's
  # auto-generated tag tarball — a deliberate deviation from the "prefer uploaded
  # assets" rule, because the preferred asset does not exist. Durable fix: have
  # CISS's release.yml publish a source tarball again, then point back at it.
  # sha256 computed from the fetched bytes 2026-08-26.
  url "https://github.com/CroftCommunity/CISS/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "e0ae7166c2a8a125dec611ca3fb4c82abc038a50507b4bf9da4acdc1a24e4e34"
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
