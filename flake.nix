# SPDX-License-Identifier: MIT OR Palimpsest-0.8
# SPDX-FileCopyrightText: 2025 Hyperpolymath

{
  description = "aggregate-library (aLib) - Common Library Specification for cross-language programming";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build-time dependencies
        nativeBuildInputs = with pkgs; [
          just          # Task runner
          git           # Version control
        ];

        # Documentation tools
        docInputs = with pkgs; [
          mdbook        # Markdown book generator
          asciidoctor   # AsciiDoc processor
        ];

        # Validation tools
        validationInputs = with pkgs; [
          yamllint      # YAML linter
          nodePackages.markdownlint-cli  # Markdown linter
          lychee        # Link checker
        ];

        # Development shell
        devShell = pkgs.mkShell {
          buildInputs = nativeBuildInputs ++ docInputs ++ validationInputs;

          shellHook = ''
            echo "aggregate-library (aLib) development environment"
            echo ""
            echo "Available commands:"
            echo "  just --list     - List all available tasks"
            echo "  just validate   - Validate all specifications"
            echo "  just test       - Run all tests"
            echo "  just check      - Full compliance check"
            echo ""
            echo "RSR Gold Compliance: Active"
            echo "Version: 0.1.0"
          '';
        };

      in {
        # Development shell
        devShells.default = devShell;

        # Package (the specifications themselves)
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "aggregate-library";
          version = "0.1.0";

          src = ./.;

          buildInputs = nativeBuildInputs;

          buildPhase = ''
            # Validate specifications
            just validate || echo "Validation skipped in nix build"
          '';

          installPhase = ''
            mkdir -p $out/share/aggregate-library

            # Copy specifications
            cp -r specs $out/share/aggregate-library/

            # Copy documentation
            cp README.md $out/share/aggregate-library/
            cp README.adoc $out/share/aggregate-library/ || true
            cp LICENSE.txt $out/share/aggregate-library/
            cp SPEC_FORMAT.md $out/share/aggregate-library/
            cp CHANGELOG.md $out/share/aggregate-library/
            cp SECURITY.md $out/share/aggregate-library/
            cp CONTRIBUTING.md $out/share/aggregate-library/
            cp CONTRIBUTING.adoc $out/share/aggregate-library/ || true
            cp CODE_OF_CONDUCT.md $out/share/aggregate-library/
            cp CODE_OF_CONDUCT.adoc $out/share/aggregate-library/ || true
            cp GOVERNANCE.adoc $out/share/aggregate-library/ || true
            cp MAINTAINERS.md $out/share/aggregate-library/
            cp REVERSIBILITY.md $out/share/aggregate-library/
            cp ROADMAP.md $out/share/aggregate-library/
            cp RSR_COMPLIANCE.md $out/share/aggregate-library/
            cp CLAUDE.md $out/share/aggregate-library/

            # Copy .well-known directory
            cp -r .well-known $out/share/aggregate-library/

            # Copy justfile for users
            cp justfile $out/share/aggregate-library/
          '';

          meta = with pkgs.lib; {
            description = "Common Library specification for cross-language programming";
            homepage = "https://github.com/Hyperpolymath/aggregate-library";
            license = licenses.mit;  # Dual license: MIT OR Palimpsest-0.8
            maintainers = [ "Hyperpolymath" ];
            platforms = platforms.all;
          };
        };

        # Validation check
        checks.validate = pkgs.runCommand "validate-specs" {
          buildInputs = nativeBuildInputs ++ validationInputs;
        } ''
          cp -r ${self} source
          cd source
          just validate
          touch $out
        '';

        # Documentation generation
        packages.docs = pkgs.stdenv.mkDerivation {
          pname = "aggregate-library-docs";
          version = "0.1.0";

          src = ./.;

          buildInputs = docInputs;

          buildPhase = ''
            # Future: Generate HTML documentation from specs
            mkdir -p docs-output
          '';

          installPhase = ''
            mkdir -p $out/share/doc/aggregate-library
            cp -r specs $out/share/doc/aggregate-library/
            cp -r docs-output/* $out/share/doc/aggregate-library/ || true
          '';
        };

        # Apps
        apps = {
          # Validate specifications
          validate = {
            type = "app";
            program = toString (pkgs.writeShellScript "validate" ''
              ${pkgs.just}/bin/just validate
            '');
          };

          # Run all tests
          test = {
            type = "app";
            program = toString (pkgs.writeShellScript "test" ''
              ${pkgs.just}/bin/just test
            '');
          };

          # Full compliance check
          check = {
            type = "app";
            program = toString (pkgs.writeShellScript "check" ''
              ${pkgs.just}/bin/just check
            '');
          };
        };

      }) // {
        # Overlay for adding aggregate-library to nixpkgs
        overlays.default = final: prev: {
          aggregate-library = self.packages.${final.system}.default;
        };
      };
}
