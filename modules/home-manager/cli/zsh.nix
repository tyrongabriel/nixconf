{ ... }:
{
  flake.modules.homeManager.cli =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.myHome.zsh;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.zsh = with lib; {
        enable = mkEnableOption "Enable zsh configuration";
      };
      config = mkIf cfg.enable {
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

        programs.fastfetch.enable = true;

        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          # Custom settings - see https://starship.rs/config/
          settings = {
            # Optionally add a preset like catppuccin to match your syntax highlighting
            # You can fetch a preset from https://github.com/catppuccin/starship
          };
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
            bindkey "^A" beginning-of-line
            bindkey "^E" end-of-line
          '';
          shellAliases = {
            # General
            ll = "eza -lag --icons";
            llt = "eza -lag --icons --tree --level 2"; # Specify --level to limit depth
            lah = "eza -lahg --icons";
            fzfb = "fzf --preview='bat --color=always {}'";
            cd = "z";
            zj = "zellij";
            zja = "zellij attach";
            zjl = "zellij list-sessions";
            # Git
            g = "git";
            ga = "git add";
            gaa = "git add --all";
            gapa = "git add --patch";
            gau = "git add --update";
            gb = "git branch";
            gba = "git branch --all";
            gbd = "git branch --delete";
            gbm = "git branch --move";
            gbnm = "git branch --no-merged";
            gbr = "git branch --remote";
            gbs = "git bisect";
            gbsb = "git bisect bad";
            gbsg = "git bisect good";
            gbss = "git bisect start";
            gc = "git commit";
            gcc = "git commit --amend";
            gca = "git commit --add";
            gcaa = "git commit --add --amend";
            gcam = "git commit --all --message";
            gcana = "git commit --all --no-edit --amend";
            gcansm = "git commit --all --squash --message";
            gcas = "git commit --all --signoff";
            gcasm = "git commit --all --signoff --message";
            gcb = "git checkout --branch";
            gcf = "git config --list";
            gcl = "git clone";
            gclean = "git clean";
            gcleanf = "git clean --force --interactive";
            gpristine = "git reset --hard && git clean --force --df";
            gd = "git diff";
            gdca = "git diff --cached";
            gdct = "git diff --cached --stat";
            gds = "git diff --staged";
            gdt = "git diff --stat";
            gdw = "git diff --word-diff";
            gf = "git fetch";
            gfa = "git fetch --all";
            gfg = "git fetch --all --tags";
            gfo = "git fetch origin";
            gg = "git gui";
            ghh = "git help";
            gignore = "git update-index --assume-unchanged";
            gignored = "git ls-files --ignored --exclude-standard";
            gl = "git pull";
            glg = "git log";
            glga = "git log --graph";
            glgg = "git log --graph --decorate";
            glgga = "git log --graph --decorate --all";
            glgm = "git log --graph --max-count=10";
            glgp = "git log --stat --patch";
            glo = "git log --oneline";
            glod = "git log --oneline --decorate";
            glods = "git log --oneline --decorate --stat";
            glogp = "git log --oneline --patch";
            glogs = "git log --oneline --stat";
            glp = "git log --pretty=format";
            glum = "git pull upstream master";
            gm = "git merge";
            gma = "git merge --abort";
            gmc = "git merge --continue";
            gmff = "git merge --no-fast-forward";
            gmffm = "git merge --no-fast-forward --message";
            gmnof = "git merge --no-ff";
            gmnofm = "git merge --no-ff --message";
            gp = "git push";
            gpd = "git push --dry-run";
            gpf = "git push --force-with-lease";
            gpff = "git push --force";
            gpoat = "git push origin --all && git push origin --tags";
            gpr = "git pull --rebase";
            gpru = "git pull --rebase upstream";
            gr = "git rebase";
            gra = "git remote add";
            grb = "git rebase";
            grba = "git rebase --abort";
            grbc = "git rebase --continue";
            grbi = "git rebase --interactive";
            grbm = "git rebase master";
            grbs = "git rebase --skip";
            grev = "git revert";
            grh = "git reset";
            grhh = "git reset --hard";
            grhm = "git reset --merge";
            grhs = "git reset --soft";
            grm = "git rm";
            grmc = "git rm --cached";
            grmv = "git remote rename";
            groh = "git reset origin HEAD";
            grp = "git remote prune";
            grrm = "git remote remove";
            grs = "git restore";
            grset = "git remote set-url";
            grss = "git restore --source";
            grst = "git restore --staged";
            grt = "git rev-parse --show-toplevel";
            gru = "git remote update";
            grup = "git remote update";
            grv = "git remote --verbose";
            gsd = "git svn dcommit";
            gsi = "git submodule init";
            gsps = "git show --pretty=format --patch";
            gsr = "git submodule update --recursive";
            gss = "git status --short";
            gst = "git status";
            gstaa = "git stash --all";
            gstc = "git stash clear";
            gstd = "git stash drop";
            gstl = "git stash list";
            gstm = "git stash pop";
            gstp = "git stash push";
            gsts = "git stash show --patch";
            gstu = "git stash --include-untracked";
            gsu = "git submodule update";
            gsw = "git switch";
            gswc = "git switch --create";
            gswm = "git switch master";
            gta = "git stash push";
            gts = "git tag --sign";
            gtv = "git tag | sort --version-sort";
            gunignore = "git update-index --no-assume-unchanged";
            gum = "git rebase --interactive --autosquash";
            gunwip = "git log --oneline --grep='WIP' --max-count=1";
            gup = "git rebase --interactive";
            gupv = "git rebase --interactive --verify";
            gwch = "git whatchanged --stat";
            gwip = "git add --all; git commit --message 'WIP'";

            # Kubernetes
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

          # oh-my-zsh removed - Starship handles the prompt now
          # If you still want the git/cp oh-my-zsh plugins, you can keep
          # oh-my-zsh with an empty theme, but it's cleaner without it.

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
          ];
          #   {
          #     name = "zsh-syntax-highlighting";
          #     file = "catppuccin_mocha-zsh-syntax-highlighting.zsh";
          #     src = pkgs.fetchFromGitHub {
          #       owner = "catppuccin";
          #       repo = "zsh-syntax-highlighting";
          #       rev = "7926c3d3e17d26b3779851a2255b95ee650bd928";
          #       hash = "sha256-l6tztApzYpQ2/CiKuLBf8vI2imM6vPJuFdNDSEi7T/o=";
          #     };
          #   }
          # ];
        };
      };
    };
}
