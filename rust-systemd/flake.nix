{
  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
    naersk.url       = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        packageName = "INSERT_NAME_HERE";
        serviceDescription = "INSERT_DESCRIPTION_HERE";

        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = (pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "cargo"
            "rustc"
            "rustfmt"
          ];
        });
        naersk-lib = naersk.lib."${system}".override {
          cargo = rust;
          rustc = rust;
        };
      in rec {
        packages.${packageName} = naersk-lib.buildPackage {
          pname = "${packageName}";
          root = ./.;
        };
        defaultPackage = packages.${packageName};

        apps.${packageName} = packages.${packageName};
        defaultApp = apps.${packageName};

        nixosModules.default = with pkgs.lib; { config, ... }:
        let cfg = config.services.${packageName};
        in {
          options.services.${packageName} = {
            enable = mkEnableOption "${serviceDescription}";
            envFile = mkOption {
              type = types.str;
              default = "/etc/${packageName}.env";
            };
          };
          config = mkIf cfg.enable {
            systemd.services.${packageName} = {
              wantedBy = [ "multi-user.target" ];
              serviceConfig.ExecStart = "${self.defaultPackage.${system}}/bin/${packageName}";
              serviceConfig.EnvironmentFile = cfg.envFile;
            };
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            rust
            pkgs.rust-analyzer
          ];
        };
      }
    );
}
