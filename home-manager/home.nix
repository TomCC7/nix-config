# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "cc";
    homeDirectory = "/home/cc";
  };

  # Add stuff for your user as you see fit:
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
  };
  programs.bash.enable = true;
  home.packages = with pkgs; [
    # DESKTOP APPS
    google-chrome
    zathura
    zotero
    code-cursor
    youtube-music
    nomacs
    element-desktop
    telegram-desktop
    # WINDOW MANAGER
    rofi-wayland
    brightnessctl
    xwayland-satellite
    kanshi
    wdisplays
    waybar
    mako
    swaybg
    swayidle
    swaylock-effects
    pavucontrol
    glmark2
    # wpctl
    # CLIS
    git
    tmux
    stow
    alacritty
    eza
    bottom
    htop
    ripgrep
    feh
    # programming
    lua
    uv
    python310
    # fonts
    meslo-lgs-nf
    nerd-fonts.meslo-lg
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  xsession.enable = true;
  systemd.user.sessionVariables = {
    UV_PYTHON_PREFERENCE = "only-system";
    UV_PYTHON = "${pkgs.python3}/bin/python";
    # wayland
    NIXOS_OZONE_WL = "1";
    DISPLAY = ":1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    # fcitx
    INPUT_METHOD = "fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };


  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # niri related systemd
  systemd.user.services = {
    # Services will be automatically linked to niri.service.wants
    mako = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        # ExecCondition = "/bin/sh -c '[ -n  \"$WAYLAND_DISPLAY\"]'";
        ExecStart = "${pkgs.mako}/bin/mako";
        ExecReload = "${pkgs.mako}/bin/makoctl reload";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
    waybar = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    swaybg = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i /home/cc/Pictures/wallpapers/alaska.jpg";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    swayidle = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 601 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
            timeout 600 '${pkgs.swaylock-effects}/bin/swaylock --clock --indicator --screenshots --effect-blur 20x2 -f' \
            before-sleep '${pkgs.swaylock-effects}/bin/swaylock --clock --indicator --screenshots --effect-blur 20x2 -f'
        '';
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };



  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
