{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.nvf;
    in
    with lib;
    {
      imports = [ inputs.nvf.homeManagerModules.default ];
      options.myHome.cli.nvf = with lib; {
        enable = mkEnableOption "Enable nvf";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # stylix.targets.neovim.enable = false;
        # stylix.targets.nvf.enable = false; # Disable stylix's nvf target to avoid conflicts
        programs.nvf =
          let
            isMaximal = false;
          in
          {
            enable = true;
            # settings = import "${inputs.nvf}/configuration.nix" {
            #   inherit pkgs;
            #   lib = pkgs.lib;
            #   isMaximal = true; # Let's use the full maximal configuration here
            # };
            # Your settings need to go into the settings attribute set
            # most settings are documented in the appendix
            settings.vim = {
              viAlias = true;
              vimAlias = true;
              debugMode = {
                enable = false;
                level = 16;
                logFile = "/tmp/nvim.log";
              };

              # Smart home toggle: if at first non-blank, go to absolute beginning; otherwise go to first non-blank
              keymaps = [
                {
                  mode = "i";
                  key = "<S-e>";
                  action = "<End>";
                }
                {
                  mode = "n";
                  key = "<S-e>";
                  action = "$";
                }
                {
                  mode = "v";
                  key = "<S-e>";
                  action = "$";
                }
                {
                  mode = "n";
                  key = "<S-b>";
                  action = "<Cmd>execute 'normal! ' . (getpos('.')[2] == 1 ? '0' : '^')<CR>";
                }
                {
                  mode = "v";
                  key = "<S-b>";
                  action = "<Cmd>execute 'normal! ' . (getpos('.')[2] == 1 ? '0' : '^')<CR>";
                }
              ];

              # vim.opts and vim.options are aliased
              opts.expandtab = true;

              spellcheck = {
                enable = true;
                programmingWordlist.enable = isMaximal;
              };

              lsp = {
                # This must be enabled for the language modules to hook into
                # the LSP API.
                enable = true;

                formatOnSave = true;
                lspkind.enable = false;
                lightbulb.enable = true;
                lspsaga.enable = false;
                trouble.enable = true;
                lspSignature.enable = !isMaximal; # conflicts with blink in maximal
                otter-nvim.enable = isMaximal;
                nvim-docs-view.enable = isMaximal;
                presets.harper.enable = isMaximal;
              };

              debugger = {
                nvim-dap = {
                  enable = true;
                  ui.enable = true;
                };
              };

              # This section does not include a comprehensive list of available language modules.
              # To list all available language module options, please visit the nvf manual.
              languages = {
                enableFormat = true;
                enableTreesitter = true;
                enableExtraDiagnostics = true;

                # Languages that will be supported in default and maximal configurations.
                nix.enable = true;
                markdown.enable = true;

                # Languages that are enabled in the maximal configuration.
                bash.enable = isMaximal;
                clang.enable = isMaximal;
                cmake.enable = isMaximal;
                css.enable = isMaximal;
                scss.enable = isMaximal;
                html.enable = isMaximal;
                json.enable = isMaximal;
                sql.enable = isMaximal;
                java.enable = isMaximal;
                kotlin.enable = isMaximal;
                typescript.enable = isMaximal;
                go.enable = isMaximal;
                lua.enable = isMaximal;
                zig.enable = isMaximal;
                python.enable = isMaximal;
                typst.enable = isMaximal;
                rust = {
                  enable = isMaximal;
                  extensions.crates-nvim.enable = isMaximal;
                };
                toml.enable = isMaximal;
                xml.enable = isMaximal;
                tex.enable = isMaximal;
                docker.enable = isMaximal;
                env.enable = isMaximal;

                # Language modules that are not as common.
                openscad.enable = false;
                arduino.enable = false;
                assembly.enable = false;
                astro.enable = false;
                nu.enable = false;
                csharp.enable = false;
                julia.enable = false;
                vala.enable = false;
                scala.enable = false;
                r.enable = false;
                gleam.enable = false;
                glsl.enable = false;
                dart.enable = false;
                ocaml.enable = false;
                elixir.enable = false;
                haskell.enable = false;
                hcl.enable = false;
                ruby.enable = false;
                fsharp.enable = false;
                just.enable = false;
                make.enable = false;
                qml.enable = false;
                jinja.enable = false;
                svelte.enable = false;
                vue.enable = false;
                liquid.enable = false;
                tera.enable = false;
                twig.enable = false;
                gettext.enable = false;
                fluent.enable = false;
                jq.enable = false;
                fish.enable = false;

                # Nim LSP is broken on Darwin and therefore
                # should be disabled by default. Users may still enable
                # `vim.languages.nim` to enable it, this does not restrict
                # that.
                # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
                nim.enable = false;
              };

              visuals = {
                nvim-scrollbar.enable = isMaximal;
                nvim-web-devicons.enable = true;
                nvim-cursorline.enable = true;
                cinnamon-nvim.enable = true;
                fidget-nvim.enable = true;

                highlight-undo.enable = true;
                blink-indent.enable = true;
                indent-blankline.enable = true;

                # Fun
                cellular-automaton.enable = false;
              };

              statusline = {
                lualine = {
                  enable = true;
                  #theme = "catppuccin";
                };
              };

              theme = {
                enable = true;
                #name = "catppuccin";
                #style = "mocha";
                transparent = true;
              };

              autopairs.nvim-autopairs.enable = true;

              # nvf provides various autocomplete options. The tried and tested nvim-cmp
              # is enabled in default package, because it does not trigger a build. We
              # enable blink-cmp in maximal because it needs to build its rust fuzzy
              # matcher library.
              autocomplete = {
                nvim-cmp.enable = !isMaximal;
                blink-cmp.enable = isMaximal;
              };

              snippets.luasnip.enable = true;

              filetree = {
                neo-tree = {
                  enable = true;
                };
              };

              tabline = {
                nvimBufferline.enable = true;
              };

              treesitter.context.enable = true;

              binds = {
                whichKey.enable = true;
                cheatsheet.enable = true;
              };

              telescope.enable = true;

              git = {
                enable = true;
                gitsigns.enable = true;
                gitsigns.codeActions.enable = false; # throws an annoying debug message
                neogit.enable = isMaximal;
              };

              minimap = {
                minimap-vim.enable = false;
                codewindow.enable = isMaximal; # lighter, faster, and uses lua for configuration
              };

              dashboard = {
                dashboard-nvim.enable = false;
                alpha.enable = isMaximal;
              };

              notify = {
                nvim-notify.enable = true;
              };

              projects = {
                project-nvim.enable = isMaximal;
              };

              utility = {
                ccc.enable = false;
                vim-wakatime.enable = false;
                diffview-nvim.enable = true;
                yanky-nvim.enable = false;
                qmk-nvim.enable = false; # requires hardware specific options
                icon-picker.enable = isMaximal;
                surround.enable = isMaximal;
                leetcode-nvim.enable = isMaximal;
                multicursors.enable = isMaximal;
                smart-splits.enable = isMaximal;
                undotree.enable = isMaximal;
                nvim-biscuits.enable = isMaximal;
                grug-far-nvim.enable = isMaximal;

                motion = {
                  hop.enable = true;
                  leap.enable = true;
                  precognition.enable = isMaximal;
                };
                images = {
                  image-nvim.enable = false;
                  img-clip.enable = isMaximal;
                };
              };

              notes = {
                neorg.enable = false;
                orgmode.enable = false;
                todo-comments.enable = true;
              };

              terminal = {
                toggleterm = {
                  enable = true;
                  lazygit.enable = true;
                };
              };

              ui = {
                borders.enable = true;
                noice.enable = false; # dont like the top center cmdline
                colorizer.enable = true;
                modes-nvim.enable = false; # the theme looks terrible with catppuccin
                illuminate.enable = true;
                breadcrumbs = {
                  enable = isMaximal;
                  navbuddy.enable = isMaximal;
                };
                smartcolumn = {
                  enable = true;
                  setupOpts.custom_colorcolumn = {
                    # this is a freeform module, it's `buftype = int;` for configuring column position
                    nix = "110";
                    ruby = "120";
                    java = "130";
                    go = [
                      "90"
                      "130"
                    ];
                  };
                };
                fastaction.enable = true;
              };

              assistant = {
                chatgpt.enable = false;
                copilot = {
                  enable = false;
                  cmp.enable = isMaximal;
                };
                codecompanion-nvim.enable = false;
                avante-nvim.enable = isMaximal;
              };

              session = {
                nvim-session-manager.enable = false;
              };

              gestures = {
                gesture-nvim.enable = false;
              };

              comments = {
                comment-nvim.enable = true;
              };

              presence = {
                neocord.enable = false;
              };
            };

          };
      };
    };
}
