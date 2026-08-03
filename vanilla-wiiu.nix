# Wii U GamePad emulator: https://github.com/vanilla-wiiu/vanilla
# Only imported on this host (see flake.nix) so other machines using this
# config don't get it.
{ lib, pkgs, ... }:

let
  vanilla-wiiu = pkgs.stdenv.mkDerivation rec {
    pname = "vanilla-wiiu";
    # Upstream has no versioned releases, only a rolling "continuous" build
    # that gets overwritten on every push to master. Pin by date; bump the
    # hash (nix-prefetch-url) if you need a newer build.
    version = "unstable-2026-08-02";

    src = pkgs.fetchurl {
      url = "https://github.com/vanilla-wiiu/vanilla/releases/download/continuous/vanilla-linux-x86_64.tar.gz";
      hash = "sha256-zGGvDYglhcMDMFQCaqKNfJsR8xAs6gqSfbhKQurgmRI=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
    buildInputs = with pkgs; [
      zlib
      polkit
      glib
      libva
      libdrm
      libglvnd
      libx11
      networkmanager
      alsa-lib
    ];

    # The archive extracts flat (./bin, ./share, ...) with no top-level dir.
    sourceRoot = ".";

    # vanilla-pipe drives the wifi interface directly (its own embedded
    # wpa_supplicant/nl80211 code) and refuses to run unless it's actually
    # root, so it's launched via pkexec. Upstream normally self-installs this
    # policy to /usr/share/polkit-1 on first run; we install it as part of
    # the package instead, pointed at our store path, so NixOS's polkit
    # module (which links every package's share/polkit-1 dir into the
    # system profile) picks it up automatically.
    passAsFile = [ "polkitPolicy" ];
    polkitPolicy = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN" "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
      <policyconfig>
        <vendor>MattKC</vendor>
        <vendor_url>https://mattkc.com</vendor_url>
        <action id="com.mattkc.vanilla">
          <description>Run Vanilla Pipe as root</description>
          <message>Authentication is required to run Vanilla Pipe as root</message>
          <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin</allow_active>
          </defaults>
          <annotate key="org.freedesktop.policykit.exec.path">@vanillaPipePath@</annotate>
          <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
        </action>
      </policyconfig>
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r bin share $out/

      mkdir -p $out/share/polkit-1/actions
      substitute "$polkitPolicyPath" $out/share/polkit-1/actions/com.mattkc.vanilla.policy \
        --replace-fail '@vanillaPipePath@' "$out/bin/vanilla-pipe"

      # NixOS has no OSS (dsp) audio device and no libpulse in this closure,
      # so SDL's default audio driver probing fails; alsa works via
      # pipewire's ALSA compatibility layer. SDL dlopen()s libasound at
      # runtime rather than linking it, so autoPatchelfHook won't wire it
      # up on its own -- put it on LD_LIBRARY_PATH explicitly.
      # Default to windowed rather than upstream's fullscreen default; pass
      # -f/--fullscreen on the command line to override.
      wrapProgram $out/bin/vanilla \
        --set SDL_AUDIODRIVER alsa \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.alsa-lib ]}" \
        --add-flags "--window"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Open source Wii U GamePad emulator";
      homepage = "https://github.com/vanilla-wiiu/vanilla";
      license = licenses.gpl2Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "vanilla";
    };
  };
in
{
  environment.systemPackages = [ vanilla-wiiu ];
}
