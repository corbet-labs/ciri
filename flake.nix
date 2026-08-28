# This flake remains close to Niri's community-maintained package expression.
{
  description = "Ciri: a close-to-upstream Niri fork with software EGL support.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      revision = self.shortRev or self.dirtyShortRev or "unknown";
      ciri-package =
        {
          lib,
          cairo,
          dbus,
          libGL,
          libdisplay-info_0_3,
          libinput,
          seatd,
          libxkbcommon,
          libgbm,
          pango,
          pipewire,
          pkg-config,
          rustPlatform,
          systemd,
          wayland,
          installShellFiles,
          withDbus ? true,
          withSystemd ? true,
          withScreencastSupport ? true,
          withDinit ? false,
        }:

        rustPlatform.buildRustPackage {
          pname = "ciri";
          version = revision;

          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./niri-config
              ./niri-ipc
              ./niri-visual-tests
              ./resources
              ./src
              ./Cargo.toml
              ./Cargo.lock
            ];
          };

          postPatch = ''
            patchShebangs resources/ciri-session
            substituteInPlace resources/ciri.service \
              --replace-fail 'ExecStart=ciri' "ExecStart=$out/bin/ciri"
          '';

          cargoLock = {
            # NOTE: This is only used for Git dependencies
            allowBuiltinFetchGit = true;
            lockFile = ./Cargo.lock;
          };

          strictDeps = true;

          nativeBuildInputs = [
            rustPlatform.bindgenHook
            pkg-config
            installShellFiles
          ];

          buildInputs =
            [
              cairo
              dbus
              libGL
              libdisplay-info_0_3
              libinput
              seatd
              libxkbcommon
              libgbm
              pango
              wayland
            ]
            ++ lib.optional (withDbus || withScreencastSupport || withSystemd) dbus
            ++ lib.optional withScreencastSupport pipewire
            # Also includes libudev
            ++ lib.optional withSystemd systemd;

          buildFeatures =
            lib.optional withDbus "dbus"
            ++ lib.optional withDinit "dinit"
            ++ lib.optional withScreencastSupport "xdp-gnome-screencast"
            ++ lib.optional withSystemd "systemd";
          buildNoDefaultFeatures = true;

          # ever since this commit:
          # https://github.com/niri-wm/niri/commit/771ea1e81557ffe7af9cbdbec161601575b64d81
          # The compositor runs a real instance with a mock backend during tests
          # and thus creates a real socket file in the runtime dir.
          # this is fine for our build, we just need to make sure it has a directory to write to.
          preCheck = ''
            export XDG_RUNTIME_DIR="$(mktemp -d)"
          '';

          checkFlags = [
            # These tests require the ability to access a "valid EGL Display", but that won't work
            # inside the Nix sandbox
            "--skip=::egl"
          ];

          postInstall =
            ''
              installShellCompletion --cmd ciri \
                --bash <($out/bin/ciri completions bash) \
                --fish <($out/bin/ciri completions fish) \
                --nushell <($out/bin/ciri completions nushell) \
                --zsh <($out/bin/ciri completions zsh)

              install -Dm644 resources/ciri.desktop -t $out/share/wayland-sessions
              install -Dm644 resources/ciri-portals.conf -t $out/share/xdg-desktop-portal
            ''
            + lib.optionalString withSystemd ''
              install -Dm755 resources/ciri-session $out/bin/ciri-session
              install -Dm644 resources/ciri{.service,-shutdown.target} -t $out/lib/systemd/user
            '';

          env = {
            # Force linking with libEGL and libwayland-client so they end up in RPATH and
            # can be discovered by `dlopen()`
            RUSTFLAGS = toString (
              map (arg: "-C link-arg=" + arg) [
                "-Wl,--push-state,--no-as-needed"
                "-lEGL"
                "-lwayland-client"
                "-Wl,--pop-state"
              ]
            );
            CIRI_BUILD_COMMIT = revision;
          };

          passthru = {
            providedSessions = [ "ciri" ];
          };

          meta = {
            description = "Scrollable-tiling Wayland compositor";
            homepage = "https://github.com/corbet-labs/ciri";
            license = lib.licenses.gpl3Plus;
            mainProgram = "ciri";
            platforms = lib.platforms.linux;
          };
        };

      inherit (nixpkgs) lib;
      # Support all Linux systems that the nixpkgs flake exposes
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      checks = forAllSystems (system: {
        # We use the debug build here to save a bit of time
        inherit (self.packages.${system}) ciri-debug;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          rustfmt' = pkgs.rustfmt.override { asNightly = true; };
          inherit (self.packages.${system}) ciri;
        in
        {
          default = pkgs.mkShell {
            packages = builtins.attrValues {
              inherit (pkgs)
                rustc
                cargo
                clippy
                cargo-insta
                ;
              inherit rustfmt';
            };

            nativeBuildInputs = [
              pkgs.rustPlatform.bindgenHook
              pkgs.pkg-config
              pkgs.wrapGAppsHook4 # For `niri-visual-tests`
            ];

            buildInputs = ciri.buildInputs ++ [
              pkgs.libadwaita # For `niri-visual-tests`
            ];

            env = {
              # WARN: Do not overwrite this variable in your shell!
              # It is required for `dlopen()` to work on some libraries; see the comment
              # in the package expression
              #
              # This should only be set with `RUSTFLAGS="$RUSTFLAGS -C your-flags"`
              RUSTFLAGS = ciri.RUSTFLAGS;
            };
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      packages = forAllSystems (
        system:
        let
          ciri = nixpkgsFor.${system}.callPackage ciri-package { };
        in
        {
          inherit ciri;

          # NOTE: This is for development purposes only
          #
          # It is primarily to help with quickly iterating on
          # changes made to the above expression - though it is
          # also not stripped in order to better debug Ciri itself
          ciri-debug = ciri.overrideAttrs (
            newAttrs: oldAttrs: {
              pname = oldAttrs.pname + "-debug";

              cargoBuildType = "debug";
              cargoCheckType = newAttrs.cargoBuildType;

              dontStrip = true;
            }
          );

          default = ciri;
        }
      );

      overlays.default = final: _: {
        ciri = final.callPackage ciri-package { };
      };
    };
}
