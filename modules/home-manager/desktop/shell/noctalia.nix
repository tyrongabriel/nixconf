{ self, inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.noctalia;
    in
    with lib;
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];
      options.myHome.desktop.noctalia = with lib; {
        enable = mkEnableOption "Enable noctalia shell for wayland";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          noctalia-qs
          brightnessctl
          imagemagick
        ];

        home.file = {
          ".face".source = ../images/catppuccin-pfp.png;
        };

        programs.noctalia-shell.enable = true;
        programs.noctalia-shell.settings = {
          bar = {
            barType = "floating";
            position = "top";
            monitors = [ ];
            density = "compact";
            showOutline = false;
            showCapsule = false;
            capsuleOpacity = 1.0;
            capsuleColorKey = "none";
            widgetSpacing = 6;
            contentPadding = 2;
            fontScale = 1;
            enableExclusionZoneInset = true;
            backgroundOpacity = 1.0;
            useSeparateOpacity = false;
            marginVertical = 4;
            marginHorizontal = 4;
            frameThickness = 8;
            frameRadius = 12;
            outerCorners = true;
            hideOnOverview = false;
            displayMode = "always_visible";
            autoHideDelay = 500;
            autoShowDelay = 150;
            showOnWorkspaceSwitch = true;
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  id = "Network";
                }
                {
                  id = "Bluetooth";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "VPN";
                  textColor = "none";
                }
                {
                  defaultSettings = {
                    compactMode = false;
                    defaultPeerAction = "copy-ip";
                    hideDisconnected = false;
                    managementUrl = "";
                    pingCount = 5;
                    refreshInterval = 5000;
                    showIpAddress = true;
                    showPing = false;
                    terminalCommand = "";
                  };
                  id = "plugin:netbird";
                }
              ];
              center = [
                {
                  hideUnoccupied = false;
                  id = "Workspace";
                  labelMode = "none";
                }
              ];
              right = [
                {
                  blacklist = [ ];
                  chevronColor = "none";
                  colorizeIcons = false;
                  drawerEnabled = false;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [ ];
                }
                {
                  defaultSettings = {
                    activeColor = "primary";
                    camFilterRegex = "";
                    enableToast = true;
                    hideInactive = false;
                    iconSpacing = 4;
                    inactiveColor = "none";
                    micFilterRegex = "";
                    removeMargins = false;
                  };
                  id = "plugin:privacy-indicator";
                }
                {
                  compactMode = true;
                  diskPath = "/";
                  iconColor = "none";
                  id = "SystemMonitor";
                  showCpuCores = false;
                  showCpuFreq = false;
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskAvailable = false;
                  showDiskUsage = false;
                  showDiskUsageAsPercent = false;
                  showGpuTemp = false;
                  showLoadAverage = false;
                  showMemoryAsPercent = false;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  showSwapUsage = false;
                  textColor = "none";
                  useMonospaceFont = true;
                  usePadding = false;
                }
                {
                  alwaysShowPercentage = true;
                  id = "Battery";
                  warningThreshold = 30;
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "KeyboardLayout";
                  showIcon = false;
                  textColor = "none";
                }
                {
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  id = "Clock";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
                {
                  defaultSettings = {
                    ai = {
                      apiKeys = { };
                      maxHistoryLength = 100;
                      model = "gemini-2.5-flash";
                      openaiBaseUrl = "https://api.openai.com/v1/chat/completions";
                      openaiLocal = false;
                      provider = "google";
                      systemPrompt = "You are a helpful assistant integrated into a Linux desktop shell. Be concise and helpful.";
                      temperature = 0.7;
                    };
                    maxHistoryLength = 100;
                    panelDetached = true;
                    panelHeightRatio = 0.85;
                    panelPosition = "right";
                    panelWidth = 520;
                    scale = 1;
                    translator = {
                      backend = "google";
                      deeplApiKey = "";
                      realTimeTranslation = true;
                      sourceLanguage = "auto";
                      targetLanguage = "en";
                    };
                  };
                  id = "plugin:assistant-panel";
                }
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = false;
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  defaultSettings = {
                    authMethod = "none";
                    authPassword = "";
                    authToken = "";
                    authUsername = "";
                    enableToasts = true;
                    maxMessages = 100;
                    pollInterval = 30;
                    readMessageIds = [ ];
                    serverUrl = "https://ntfy.sh";
                    topics = "";
                  };
                  id = "plugin:ntfy-notifications";
                }
              ];
            };
            mouseWheelAction = "none";
            reverseScroll = false;
            mouseWheelWrap = true;
            middleClickAction = "none";
            middleClickFollowMouse = false;
            middleClickCommand = "";
            rightClickAction = "controlCenter";
            rightClickFollowMouse = true;
            rightClickCommand = "";
            screenOverrides = [ ];
          };

          general = {
            avatarImage = "/home/${config.home.username}/.face";
            dimmerOpacity = 0.2;
            showScreenCorners = false;
            forceBlackScreenCorners = false;
            scaleRatio = 1;
            radiusRatio = 0.2;
            iRadiusRatio = 1;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1;
            animationDisabled = false;
            compactLockScreen = false;
            lockScreenAnimations = false;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            showHibernateOnLockScreen = false;
            enableLockScreenMediaControls = false;
            enableShadows = true;
            enableBlurBehind = true;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            language = "";
            allowPanelsOnScreenWithoutBar = true;
            showChangelogOnStartup = true;
            telemetryEnabled = false;
            enableLockScreenCountdown = true;
            lockScreenCountdownDuration = 5000;
            autoStartAuth = false;
            allowPasswordWithFprintd = false;
            clockStyle = "custom";
            clockFormat = "hh\\nmm";
            passwordChars = false;
            lockScreenMonitors = [ ];
            lockScreenBlur = 0;
            lockScreenTint = 0;
            keybinds = {
              keyUp = [ "Up" ];
              keyDown = [ "Down" ];
              keyLeft = [ "Left" ];
              keyRight = [ "Right" ];
              keyEnter = [
                "Return"
                "Enter"
              ];
              keyEscape = [ "Esc" ];
              keyRemove = [ "Del" ];
            };
            reverseScroll = false;
            smoothScrollEnabled = true;
          };

          ui = {
            fontDefault = "DejaVu Sans";
            fontFixed = "JetBrainsMono Nerd Font Mono";
            fontDefaultScale = 1;
            fontFixedScale = 1;
            tooltipsEnabled = true;
            scrollbarAlwaysVisible = true;
            boxBorderEnabled = false;
            panelBackgroundOpacity = 1.0;
            translucentWidgets = false;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            settingsPanelSideBarCardStyle = false;
          };

          location = {
            name = "Vienna, Austria";
            weatherEnabled = true;
            weatherShowEffects = true;
            weatherTaliaMascotAlways = false;
            useFahrenheit = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = false;
            showCalendarEvents = true;
            showCalendarWeather = true;
            analogClockInCalendar = false;
            firstDayOfWeek = -1;
            hideWeatherTimezone = false;
            hideWeatherCityName = false;
            autoLocate = false;
          };

          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };

          wallpaper = {
            enabled = true;
            overviewEnabled = false;
            directory = "/home/tyron/Pictures/Wallpapers";
            monitorDirectories = [ ];
            enableMultiMonitorDirectories = false;
            showHiddenFiles = false;
            viewMode = "single";
            setWallpaperOnAllMonitors = true;
            linkLightAndDarkWallpapers = true;
            fillMode = "crop";
            fillColor = "#000000";
            useSolidColor = false;
            solidColor = "#1a1a2e";
            automationEnabled = false;
            wallpaperChangeMode = "random";
            randomIntervalSec = 300;
            transitionDuration = 1500;
            transitionType = [
              "fade"
              "disc"
              "stripes"
              "wipe"
              "pixelate"
              "honeycomb"
            ];
            skipStartupTransition = false;
            transitionEdgeSmoothness = 0.05;
            panelPosition = "follow_bar";
            hideWallpaperFilenames = false;
            useOriginalImages = false;
            overviewBlur = 0.4;
            overviewTint = 0.6;
            useWallhaven = false;
            wallhavenQuery = "";
            wallhavenSorting = "relevance";
            wallhavenOrder = "desc";
            wallhavenCategories = "111";
            wallhavenPurity = "100";
            wallhavenRatios = "";
            wallhavenApiKey = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenResolutionHeight = "";
            sortOrder = "name";
            favorites = [ ];
          };

          appLauncher = {
            enableClipboardHistory = false;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            enableClipboardSmartIcons = true;
            enableClipboardChips = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            position = "center";
            pinnedApps = [ ];
            sortByMostUsed = true;
            terminalCommand = "kitty -e";
            customLaunchPrefixEnabled = false;
            customLaunchPrefix = "";
            viewMode = "list";
            showCategories = true;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            enableSessionSearch = true;
            ignoreMouseInput = false;
            screenshotAnnotationTool = "";
            overviewLayer = true;
            density = "compact";
          };

          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "WallpaperSelector"; }
                { id = "NoctaliaPerformance"; }
                { id = "AirplaneMode"; }
              ];
              right = [
                { id = "Notifications"; }
                { id = "PowerProfile"; }
                { id = "KeepAwake"; }
                { id = "NightLight"; }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };

          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            gpuCriticalThreshold = 90;
            memWarningThreshold = 80;
            memCriticalThreshold = 90;
            swapWarningThreshold = 80;
            swapCriticalThreshold = 90;
            diskWarningThreshold = 80;
            diskCriticalThreshold = 90;
            diskAvailWarningThreshold = 20;
            diskAvailCriticalThreshold = 10;
            batteryWarningThreshold = 20;
            batteryCriticalThreshold = 5;
            enableDgpuMonitoring = true;
            useCustomColors = false;
            warningColor = "";
            criticalColor = "";
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          };

          noctaliaPerformance = {
            disableWallpaper = false;
            disableDesktopWidgets = true;
          };

          dock = {
            enabled = true;
            position = "bottom";
            displayMode = "auto_hide";
            dockType = "floating";
            backgroundOpacity = 1.0;
            floatingRatio = 1;
            size = 1;
            onlySameOutput = true;
            monitors = [ ];
            pinnedApps = [ ];
            colorizeIcons = false;
            showLauncherIcon = false;
            launcherPosition = "end";
            launcherUseDistroLogo = false;
            launcherIcon = "";
            launcherIconColor = "none";
            pinnedStatic = false;
            inactiveIndicators = false;
            groupApps = false;
            groupContextMenuMode = "extended";
            groupClickAction = "cycle";
            groupIndicatorStyle = "dots";
            deadOpacity = 0.6;
            animationSpeed = 1;
            sitOnFrame = false;
            showDockIndicator = false;
            indicatorThickness = 3;
            indicatorColor = "primary";
            indicatorOpacity = 0.6;
          };

          network = {
            bluetoothRssiPollingEnabled = false;
            bluetoothRssiPollIntervalMs = 60000;
            networkPanelView = "wifi";
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
            disableDiscoverability = false;
            bluetoothAutoConnect = true;
          };

          sessionMenu = {
            enableCountdown = true;
            countdownDuration = 5000;
            position = "center";
            showHeader = true;
            showKeybinds = true;
            largeButtonsStyle = true;
            largeButtonsLayout = "single-row";
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "1";
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "2";
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "3";
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "4";
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "5";
              }
              {
                action = "rebootToUefi";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
              {
                action = "userspaceReboot";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
            ];
          };

          notifications = {
            enabled = true;
            enableMarkdown = false;
            density = "default";
            monitors = [ ];
            location = "top_right";
            overlayLayer = true;
            backgroundOpacity = 1.0;
            respectExpireTimeout = false;
            lowUrgencyDuration = 3;
            normalUrgencyDuration = 8;
            criticalUrgencyDuration = 15;
            clearDismissed = true;
            saveToHistory = {
              low = true;
              normal = true;
              critical = true;
            };
            sounds = {
              enabled = false;
              volume = 0.5;
              separateSounds = false;
              criticalSoundFile = "";
              normalSoundFile = "";
              lowSoundFile = "";
              excludedApps = "discord,firefox,chrome,chromium,edge";
            };
            enableMediaToast = false;
            enableKeyboardLayoutToast = true;
            enableBatteryToast = true;
          };

          osd = {
            enabled = true;
            location = "top_right";
            autoHideMs = 2000;
            overlayLayer = true;
            backgroundOpacity = 1.0;
            enabledTypes = [
              0
              1
              2
            ];
            monitors = [ ];
          };

          audio = {
            volumeStep = 5;
            volumeOverdrive = false;
            spectrumFrameRate = 30;
            visualizerType = "linear";
            spectrumMirrored = true;
            mprisBlacklist = [ ];
            preferredPlayer = "";
            volumeFeedback = false;
            volumeFeedbackSoundFile = "";
          };

          brightness = {
            brightnessStep = 5;
            enforceMinimum = true;
            enableDdcSupport = false;
            backlightDeviceMappings = [ ];
          };

          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = "Noctalia (default)";
            darkMode = true;
            schedulingMode = "off";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "tonal-spot";
            monitorForColors = "";
            syncGsettings = true;
          };

          templates = {
            activeTemplates = [ ];
            enableUserTheming = false;
          };

          nightLight = {
            enabled = false;
            forced = false;
            autoSchedule = true;
            nightTemp = "4000";
            dayTemp = "6500";
            manualSunrise = "06:30";
            manualSunset = "18:30";
          };

          hooks = {
            enabled = false;
            wallpaperChange = "";
            darkModeChange = "";
            screenLock = "";
            screenUnlock = "";
            performanceModeEnabled = "";
            performanceModeDisabled = "";
            startup = "";
            session = "";
            colorGeneration = "";
          };

          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
          };

          idle = {
            enabled = false;
            screenOffTimeout = 600;
            lockTimeout = 660;
            suspendTimeout = 1800;
            fadeDuration = 5;
            screenOffCommand = "";
            lockCommand = "";
            suspendCommand = "";
            resumeScreenOffCommand = "";
            resumeLockCommand = "";
            resumeSuspendCommand = "";
            customCommands = "[]";
          };

          desktopWidgets = {
            enabled = false;
            overviewEnabled = true;
            gridSnap = false;
            gridSnapScale = false;
            monitorWidgets = [ ];
          };
        };
      };
    };
}
