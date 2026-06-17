{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.zed-editor;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.zed-editor = with lib; {
        enable = mkEnableOption "Enable zed-editor";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        home.packages = with pkgs; [
          python3 # Needed for JDTLS
          #cargo
          #rustc
          #rust-analyzer
          #rustfmt
          license-go
          gitlab-ci-ls # Language server for the gitlab ci
          gcc # For rustup
        ];
        # https://mynixos.com/home-manager/options/programs.zed-editor
        # https://github.com/nathansbradshaw/zed-angular
        programs.zed-editor = {
          enable = true;
          package = pkgs.unstable-small.zed-editor;
          extensions = [
            "justfile"
            "ini"
            "nix"
            "dockerfile"
            "ruff"
            "catppuccin"
            "catppuccin-icons"
            "java"
            "log"
            "sql"
            "html"
            "scss"
            "toml"
            "git-firefly"
            "xml"
            "gitlab-ci-ls"
          ];
          userKeymaps = [
            {
              context = "Workspace";
              bindings = {
                "shift shift" = "file_finder::Toggle";
              };
            }
          ];

          #https://zed.dev/docs/configuring-zed#direnv-integration
          userSettings = {
            agent_servers = {
              opencode = {
                default_model = "opencode/gpt-5-nano/high";
                type = "registry";
              };
            };
            load_direnv = "shell_hook";
            agent = {
              sidebar_side = "right";
              dock = "right";
              commit_message_model = {
                provider = "opencode";
                model = "go/minimax-m2.7";
              };
              commit_message_instructions = ''
                # Git Commit Rules

                You are an expert assistant strictly tasked with generating Git commit messages. Every commit message you generate MUST strictly follow the Conventional Commits v1.0.0 specification.

                Keep all commit messages clear, concise, and structured.

                ## Specification

                1. **Format:** `type(scope)!: description` followed by an optional body and footer(s).
                2. **Types:**
                    - `feat`: When adding a new feature.
                    - `fix`: When fixing a bug.
                    - Other allowed types: `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`.
                3. **Scope:** Optional noun describing a section of the codebase surrounded by parentheses (e.g., `fix(parser):`).
                4. **Breaking Changes:** Must be indicated by a `!` right before the colon (e.g., `feat(api)!:`) or as a `BREAKING CHANGE:` entry in the footer. "BREAKING CHANGE" must be uppercase.
                5. **Description:** A short summary of the code changes immediately following the colon and space.
                6. **Body/Footer:** A longer free-form body is optional (separated by a blank line). One or more footers may follow the body after a blank line.

                ## Examples

                - **Simple feature:** `feat: allow provided config object to extend other configs`
                - **With Scope:** `feat(lang): add Polish language`
                - **No body (docs):** `docs: correct spelling of CHANGELOG`
                - **Breaking change with !:** `feat!: send an email to the customer when a product is shipped`
                - **Breaking change with scope and !:** `feat(api)!: send an email to the customer when a product is shipped`
                - **Multi-paragraph body with footers:**
                  ```fix: prevent racing of requests

                  Introduce a request id and a reference to latest request. Dismiss incoming responses other than from latest request.

                  Reviewed-by: Z
                  Refs: #123
                  ```
                  - **Breaking change footer:**
                  ```
                  feat: allow provided config object to extend other configs

                  BREAKING CHANGE: `extends` key in config file is now used for extending other config files
                  ```

                Always analyze the provided code changes or diff, determine the correct type and scope, and output only the commit message.

                DO NOT add imaginary refs to issues, or a reviewed by note!

                ## Formatting
                Do NOT wrap the output inside of ``` and do NOT add any newlines before the text, simply output the text, beginning directly with the feat, fix, refactor etc.
              '';

              favorite_models = [
                {
                  provider = "opencode";
                  model = "go/glm-5.1";
                  enable_thinking = false;
                }
                {
                  provider = "opencode";
                  model = "go/kimi-k2.6";
                  enable_thinking = false;
                }
                {
                  provider = "opencode";
                  model = "go/qwen3.7-max";
                  enable_thinking = false;
                }
                {
                  provider = "opencode";
                  model = "go/minimax-m2.7";
                  enable_thinking = false;
                }

              ];
              profiles = {
                none = {
                  name = "Internet";
                  tools = {
                    thinking = true;
                    search_web = true;
                    copy_path = false;
                    fetch = true;
                    grep = true;
                  };
                  enable_all_context_servers = false;
                  context_servers = { };
                };
              };
              #version = "2";
              enabled = true;
              default_profile = "minimal";
              default_model = {
                enable_thinking = false;
                provider = "opencode";
                model = "go/qwen3.7-max";
              };
            };

            language_models = {
              opencode = {
                show_free_models = true;
                show_zen_models = false;
              };
              openai_compatible = {
                Cerebras = {
                  api_url = "https://api.cerebras.ai/v1";
                  available_models = [
                    {
                      display_name = "GPT OSS 120B";
                      name = "gpt-oss-120b";
                      max_tokens = 131072;
                      max_output_tokens = 40000;
                      max_completion_tokens = 200000;
                      capabilities = {
                        tools = true;
                        images = false;
                        parallel_tool_calls = true;
                        prompt_cache_key = false;
                      };
                    }
                    {
                      display_name = "Z.AI:Cerebras GLM-4.7";
                      name = "zai-glm-4.7";
                      max_tokens = 131072;
                      max_output_tokens = 40000;
                      max_completion_tokens = 200000;
                      capabilities = {
                        tools = true;
                        images = false;
                        parallel_tool_calls = true;
                        prompt_cache_key = false;
                      };
                    }
                  ];
                };
                "Z.AI" = {
                  api_url = "https://api.z.ai/api/paas/v4/";
                  available_models = [
                    {
                      capabilities = {
                        images = false;
                        parallel_tool_calls = true;
                        prompt_cache_key = false;
                        tools = true;
                      };
                      display_name = "Z.AI GLM-4.7";
                      max_tokens = 200000;
                      max_completion_tokens = 128000;
                      name = "glm-4.7";
                    }
                  ];
                };
              };
            };
            edit_predictions = {
              provider = "copilot";
            };
            telemetry = {
              metrics = false;
            };

            #theme = lib.mkForce "Catppuccin Mocha";
            icon_theme = {
              mode = "system";
              light = "Catppuccin Mocha";
              dark = "Catppuccin Mocha";
            };

            ui_font_family = "DejaVu Sans";
            ui_font_size = 16.0;
            buffer_font_family = "JetBrainsMono Nerd Font Mono";
            buffer_font_size = 16.0;

            project_panel = {
              dock = "left";
            };

            vim_mode = false;
            #ui_font_size = 16;
            #buffer_font_size = 16;
            # https://github.com/zed-extensions/nix

            languages = {
              Python = {
                language_servers = [
                  "ty"
                  "!basedpyright"
                  "..."
                ];
              };
              TypeScript = {
                language_servers = [
                  "angular"
                  "..."
                ];
              };
              HTML = {
                language_servers = [
                  "angular"
                  "..."
                ];
              };
              Nix = {
                language_servers = [
                  "nixd"
                  "!nil"
                ];
                formatter = {
                  external = {
                    command = "nixfmt";
                  };
                };
              };
            };
            inlay_hints = {
              enabled = true;
            };
            diagnostics = {
              include_warnings = true;
              inline = {
                enabled = true;
                update_debounce_ms = 150;
                padding = 4;
                min_column = 0;
                max_severity = null;
              };
            };
            lsp = {
              jdtls = {
                initialization_options = {
                  bundles = [ ];
                  settings = {
                    java = {
                      errors = {
                        incompleteClasspath = {
                          severity = "warning";
                        };
                      };
                      configuration = {
                        updateBuildConfiguration = "interactive";
                        maven = {
                          userSettings = null;
                        };
                      };
                      trace = {
                        server = "verbose";
                      };
                      import = {
                        gradle = {
                          enabled = true;
                        };
                        maven = {
                          enabled = true;
                        };
                        exclusions = [
                          "**/node_modules/**"
                          "**/.metadata/**"
                          "**/archetype-resources/**"
                          "**/META-INF/maven/**"
                          "/**/test/**"
                        ];
                      };
                      jdt = {
                        ls = {
                          lombokSupport = {
                            enabled = false; # Set this to true to enable lombok support
                          };
                        };
                      };
                      referencesCodeLens = {
                        enabled = false;
                      };
                      signatureHelp = {
                        enabled = false;
                      };
                      implementationsCodeLens = {
                        enabled = false;
                      };
                      format = {
                        enabled = true;
                      };
                      saveActions = {
                        organizeImports = false;
                      };
                      contentProvider = {
                        preferred = null;
                      };
                      autobuild = {
                        enabled = false;
                      };
                      completion = {
                        favoriteStaticMembers = [
                          "org.junit.Assert.*"
                          "org.junit.Assume.*"
                          "org.junit.jupiter.api.Assertions.*"
                          "org.junit.jupiter.api.Assumptions.*"
                          "org.junit.jupiter.api.DynamicContainer.*"
                          "org.junit.jupiter.api.DynamicTest.*"
                        ];
                        importOrder = [
                          "java"
                          "javax"
                          "com"
                          "org"
                        ];
                      };
                    };
                  };
                };
              };
              nixd = {
                settings = {
                  diagnostic = {
                    suppress = [ "sema-extra-with" ];
                  };

                  nixpkgs = {
                    expr = "import <nixpkgs> { }";
                  };

                  options = {
                    # nixos = {
                    #   expr = "(builtins.getFlake \"/home/tyron/nixos-config\").nixosConfigurations.yoga.options";
                    # };
                    # home-manager = {
                    #   expr = "(builtins.getFlake \"/home/tyron/nixos-config\").homeConfigurations.\"tyron@yoga\".options";
                    # };
                    # home-manager-standalone = {
                    #   expr = "(myFlake: builtins.foldl' (acc: cfgName: acc // (myFlake.homeConfigurations.\"\${cfgName}\".options or {})) {} (builtins.attrNames myFlake.homeConfigurations)) (builtins.getFlake (toString ./.))";

                    #   #"expr": "(builtins.getFlake \"/home/tyron/tynix\").nixosConfigurations.\"testvm\".options.home-manager.users.type.getSubOptions []"
                    #   #expr = "((myFlake: builtins.foldl' (acc: cfgName: acc // (myFlake.nixosConfigurations.\"\${cfgName}\".options or {})) {} (builtins.attrNames myFlake.nixosConfigurations)) (builtins.getFlake \"/home/tyron/nixos-config\")).home-manager.users.type.getSubOptions []";
                    # };
                    nixos = {
                      #"expr": "(builtins.getFlake \"/home/tyron/tynix\").nixosConfigurations.\"testvm\".options"
                      expr = "(myFlake: builtins.foldl' (acc: cfgName: acc // (myFlake.nixosConfigurations.\"\${cfgName}\".options or {})) {} (builtins.attrNames myFlake.nixosConfigurations)) (builtins.getFlake (toString ./.))";
                      #expr = "(let pkgs = import <nixpkgs> { }; in (pkgs.lib.evalModules { modules =  (import <nixpkgs/nixos/modules/module-list.nix>) ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options";
                    };
                    # nix = {
                    #   expr = "((myFlake: builtins.foldl' (acc: cfgName: acc // (myFlake.nixosConfigurations.\"\${cfgName}\".options or {})) {} (builtins.attrNames myFlake.nixosConfigurations)) (builtins.getFlake (toString ./.)))";
                    # };
                    home-manager = {
                      expr = "((myFlake: builtins.foldl' (acc: cfgName: acc // (myFlake.nixosConfigurations.\"\${cfgName}\".options.home-manager.users.type.getSubOptions [])) {} (builtins.attrNames myFlake.nixosConfigurations)) (builtins.getFlake (toString ./.)))";
                    };
                  };
                };

                initialization_options = {
                  formatting = {
                    command = [ "nixfmt" ];
                  };

                };
              };

            };
          };

        };

        # Agents.md
        # home.file.".config/zed/AGENTS.md".text = ''
        #   '';

        # Activation hook: if the managed zed settings file is a symlink,
        # remove it and copy its contents (so that it becomes writable).
        # The file created by home-manager is placed at ~/.config/zed/settings.json.
        # Activation hook: adjust the zed settings file so that it's not a symlink.
        # This block runs after the writeBoundary and uses the provided run and verboseEcho functions.
        home.activation.makeZedWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          echo "Starting to move the settings.json file to a writable file"
          ls -l $HOME/.config/zed/
          echo "Now copying the settings.json file to a writable file"
          if [ -f $HOME/.config/zed/settings.json ]; then
            run cp $HOME/.config/zed/settings.json $HOME/.config/zed/settings.json.tmp
            run rm $HOME/.config/zed/settings.json -f
            run cp $HOME/.config/zed/settings.json.tmp $HOME/.config/zed/settings.json
            run rm $HOME/.config/zed/settings.json.tmp -f
            run rm $HOME/.config/zed/settings.json.bak -f
            run chmod +w $HOME/.config/zed/settings.json
            echo "Done, settings.json now a regular file"
          else
            echo "settings.json not found, skipping"
          fi
        '';

      };
    };
}
