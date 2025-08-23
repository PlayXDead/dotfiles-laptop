{
  inputs = {
    zen-browser.url = "https://flakehub.com/f/make-42/zen-browser/0.1.218.tar.gz";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # ...

  outputs = {nixpkgs, zen-browser, ...} @ inputs: {
    nixosConfigurations.AWildPlaybox = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # this is the important part
      modules = [
        ./configuration.nix
      ];
    };
  };
}
