{
  description = "feenx-infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          packages = [
            docker
            docker-compose
            neovim
            wakeonlan
            talosctl
            kubectl
            kubernetes-helm
            opentofu
            go
            k9s
            gh
            fluxcd
            cilium-cli

            # Alias scripts, workaround for https://github.com/direnv/direnv/issues/73
            (pkgs.writeShellScriptBin "tf" "tofu $@")
            (pkgs.writeShellScriptBin "tctl" "talosctl $@")
            (pkgs.writeShellScriptBin "k" "kubectl $@")
            (pkgs.writeShellScriptBin "h" "helm $@")
          ];
        };
      }
    );
}