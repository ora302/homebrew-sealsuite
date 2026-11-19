# frozen_string_literal: true

# Installs the SealSuite CLI and defines its user-level SOCKS5 service.
class Sealsuite < Formula
  desc "VPN client with userspace SOCKS5 mode"
  homepage "https://github.com/ora302/homebrew-sealsuite"
  url "https://github.com/ora302/homebrew-sealsuite/releases/download/v1.9.25/SealSuite-CLI-v1.9.25-macos-arm64.tar.xz"
  sha256 "ef5a268bafb9ce27d346aa09ed18e59f3e23d16d8f47486da1949099f74cf284"

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "SealSuite"
    (etc/"sealsuite").install "config.json" => "config.json.release-example"
    (buildpath/"config.json.example").write <<~JSON
      {
        "company_name": "company code name",
        "username": "your_name",
        "password": "your_pass",
        "platform": "ldap",
        "socks5_listen": "127.0.0.1:1080"
      }
    JSON
    (etc/"sealsuite").install "config.json.example"
  end

  def caveats
    <<~EOS
      Create the active SOCKS5 configuration:
        cp #{etc}/sealsuite/config.json.example #{etc}/sealsuite/config.json
        chmod 600 #{etc}/sealsuite/config.json

      Complete interactive authentication once:
        #{bin}/SealSuite #{etc}/sealsuite/config.json

      Then start the user service:
        brew services start sealsuite

      Logs:
        #{var}/log/sealsuite.log
        #{var}/log/sealsuite-error.log
    EOS
  end

  service do
    run [opt_bin/"SealSuite", etc/"sealsuite/config.json"]
    environment_variables CORPLINK_LOG_STREAM: "stdout"
    keep_alive true
    log_path var/"log/sealsuite.log"
    error_log_path var/"log/sealsuite-error.log"
  end

  test do
    assert_match "Path to config file", shell_output("#{bin}/SealSuite --help")
    assert_path_exists etc/"sealsuite/config.json.example"
  end
end
