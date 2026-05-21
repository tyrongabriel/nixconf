{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.onlyoffice;
      stylixColors = config.lib.stylix.colors;
      # Catppuccin Mocha dark theme for OnlyOffice
      onlyofficeTheme = {
        name = "Catppuccin Mocha";
        l10n = { };
        id = "theme-catppuccin-mocha";
        type = "dark";
        colors = {
          # Header toolbar colors - using blue/mauve for document editors
          "toolbar-header-document" = "#${stylixColors.base0D}";
          "toolbar-header-spreadsheet" = "#${stylixColors.base0B}";
          "toolbar-header-presentation" = "#${stylixColors.base0E}";
          "text-toolbar-header-on-background-document" = "#${stylixColors.base05}";
          "text-toolbar-header-on-background-spreadsheet" = "#${stylixColors.base05}";
          "text-toolbar-header-on-background-presentation" = "#${stylixColors.base05}";
          # Background colors
          "background-normal" = "#${stylixColors.base00}";
          "background-toolbar" = "#${stylixColors.base01}";
          "background-toolbar-additional" = "#${stylixColors.base02}";
          "background-primary-dialog-button" = "#${stylixColors.base0D}";
          "background-accent-button" = "#${stylixColors.base0E}";
          "background-tab-underline" = "#${stylixColors.base03}";
          "background-notification-popover" = "#${stylixColors.base01}";
          "background-notification-badge" = "#${stylixColors.base09}";
          "background-contrast-popover" = "#${stylixColors.base02}";
          # Highlight colors
          "highlight-button-hover" = "#${stylixColors.base03}";
          "highlight-button-pressed" = "#${stylixColors.base04}";
          "highlight-primary-dialog-button-hover" = "#${stylixColors.base0D}";
          "highlight-accent-button-hover" = "#${stylixColors.base0E}";
          "highlight-text-select" = "#${stylixColors.base0D}";
          # Border colors
          "border-toolbar" = "#${stylixColors.base03}";
          "border-divider" = "#${stylixColors.base04}";
          "border-regular-control" = "#${stylixColors.base04}";
          # Text colors
          "text-normal" = "#${stylixColors.base05}";
          "text-secondary" = "#${stylixColors.base04}";
          "text-tertiary" = "#${stylixColors.base03}";
          "text-link" = "#${stylixColors.base0D}";
          "text-inverse" = "#${stylixColors.base05}";
          "text-toolbar-header" = "#${stylixColors.base05}";
          "text-contrast-background" = "#${stylixColors.base00}";
          # Icon colors
          "icon-normal" = "#${stylixColors.base05}";
          "icon-inverse" = "#${stylixColors.base00}";
          "icon-toolbar-header" = "#${stylixColors.base05}";
          "icon-notification-badge" = "#${stylixColors.base00}";
          "icon-success" = "#${stylixColors.base0B}";
          # Canvas colors
          "canvas-background" = "#${stylixColors.base00}";
          "canvas-content-background" = "#${stylixColors.base01}";
          "canvas-page-border" = "#${stylixColors.base03}";
          "canvas-ruler-background" = "#${stylixColors.base01}";
          "canvas-ruler-border" = "#${stylixColors.base03}";
          "canvas-ruler-margins-background" = "#${stylixColors.base02}";
          "canvas-cell-border" = "#${stylixColors.base03}";
          "canvas-cell-title-text" = "#${stylixColors.base05}";
          "canvas-cell-title-background" = "#${stylixColors.base02}";
          "canvas-scroll-thumb" = "#${stylixColors.base03}";
          "canvas-scroll-arrow" = "#${stylixColors.base04}";
        };
      };
      themeJson = builtins.toJSON onlyofficeTheme;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.onlyoffice = with lib; {
        enable = mkEnableOption "Enable onlyoffice";
      };
      config = mkIf cfg.enable {
        programs.onlyoffice = {
          enable = true;
          settings = {
            UITheme = "theme-catppuccin-mocha";
            editorWindowMode = false;
            forcedRtl = false;
            maximized = true;
            titlebar = "custom";
          };
        };

        # Write the custom theme JSON to OnlyOffice's themes directory
        # OnlyOffice Desktop looks in ~/.config/onlyoffice/themes/ for custom themes
        home.file."${config.xdg.configHome}/onlyoffice/themes/catppuccin-mocha.json".text = themeJson;
      };
    };
}
