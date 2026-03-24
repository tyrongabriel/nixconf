{ ... }:
{
  flake.modules.home-manager.core =
    { pkgs, lib, ... }:
    with lib;
    {
      home.packages = with pkgs; [
        eza
        exiftool
        bat
        chafa
      ];

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.eza = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion.enable = lib.mkDefault true;
        #initExtra = "neofetch";
        ## Content at the very end:
        initContent = mkAfter ''
          unalias gcd 2>/dev/null
          export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH" # Needed for kubectl plugins
        '';
        shellAliases = {
          ll = "eza -lag --icons";
          llt = "eza -lag --icons --tree --level 2"; # Specify --level to limit depth
          lah = "eza -lahg --icons";
          fzfb = "fzf --preview='bat --color=always {}'";
          cd = "z";
          k = "kubectl";
          kns = "kubens";
          kctx = "kubectx";
          kg = "kubectl get";
          kgp = "kubectl get pods";
          kgs = "kubectl get services";
          kgd = "kubectl get deployments";
          kgds = "kubectl get deployments -o wide";
          kgrs = "kubectl get replicasets";
          kgrss = "kubectl get replicasets -o wide";
          kgrsp = "kubectl get replicasets -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'";
          kgrsps = "kubectl get replicasets -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'";
          kgr = "kubectl get replicasets";
          kgrp = "kubectl get replicasets -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'";
          kgrps = "kubectl get replicasets -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'";
          kgc = "kubectl get configmaps";
          kgcs = "kubectl get configmaps -o wide";
        };
        syntaxHighlighting.enable = lib.mkDefault true;
        oh-my-zsh = {
          enable = lib.mkDefault true;
          theme = "frisk"; # "lambda";
          plugins = [
            "git"
            "cp" # Progress bar cp
            #"zoxide"
            #"zsh"
            #"fzf-zsh-plugin"
          ];
        };

        # nix-prefetch-github <owner> <repo>
        plugins = [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.8.0";
              sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
            };
          }
          {
            name = "zsh-syntax-highlighting";
            file = "catppuccin_mocha-zsh-syntax-highlighting.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "zsh-syntax-highlighting";
              rev = "7926c3d3e17d26b3779851a2255b95ee650bd928";
              hash = "sha256-l6tztApzYpQ2/CiKuLBf8vI2imM6vPJuFdNDSEi7T/o=";
            };
          }
          # {
          #   name = "fzf-zsh-plugin";
          #   file = "fzf-zsh-plugin.plugin.zsh";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "unixorn";
          #     repo = "fzf-zsh-plugin";
          #     rev = "909f0b8879481eab93741fa284a7d1d13cf6f79e";
          #     hash = "sha256-RILk4dHYk6yL7wmdRqmOf6JsyyoKNbbT6dHa5ExAAP0=";
          #   };
          # }
        ];

      };
    };
}
