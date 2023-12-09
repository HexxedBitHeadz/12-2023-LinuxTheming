#! /bin/bash

# Installing required software:
sudo apt install bspwm dunst firefox-esr i3lock imagemagick libnotify-bin mousepad neofetch nitrogen nnn picom polybar rofi sxhkd terminator xinit xorg unzip -y

# Making directories for .config setup:
cd ~/.config/ && mkdir -p bspwm sxhkd polybar rofi picom dunst wallpaper

# Copying example config files into our .config:
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/
cp /usr/share/doc/picom/examples/picom.sample.conf ~/.config/picom/picom.conf
cp /etc/xdg/dunst/dunstrc ~/.config/dunst/
cp /etc/polybar/config.ini ~/.config/polybar/

# making bspwmrc config and executing within xinitrc
chmod +x ~/.config/bspwm/bspwmrc
echo "exec bspwm" > ~/.xinitrc

# Setting up sxhkdrc:
cat << 'EOL' > ~/.config/sxhkd/sxhkdrc

# terminal emulator
ctrl + 1
	terminator

ctrl + 2
	rofi -show run

ctrl + 3
	firefox

# focus the next/previous window in the current desktop
ctrl + 9
	bspc node -f {next,prev}.local.!hidden.window

# alternate between the tiled and monocle layout
ctrl + 0
	bspc desktop -l next

# close and kill
ctrl + {_,shift + } q
	bspc node -{c,k}

ctrl + {_,shift + } l
	i3lock -i ~/.config/wallpaper/lockscreen.png && notify-send "Screen Locked"

# make sxhkd reload its configuration files:
ctrl + alt + r
	pkill -USR1 -x sxhkd && notify-send "sxhkd reloaded!"

# Cycle node focus
alt + c
    bspc node -f {next.local,prev.local}

# Change focus to biggest node
alt + v
	bspc node -f biggest.local

# Change focus to smallest node
alt + x
	bspc node -f smallest.local

# # Promote to master
alt + space
	bspc node -s biggest.local

# Equalize size of all windows
alt + z
	bspc node @/ --equalize

# Rotate windows clockwise and anticlockwise
ctrl + r
    bspc node @/ --circulate {backward,forward}

# expand and contract window node
ctrl + alt + {Left,Down,Up,Right}
  n=10; \
  { d1=left;   d2=right;  dx=-$n; dy=0;   \
  , d1=bottom; d2=top;    dx=0;   dy=$n;  \
  , d1=top;    d2=bottom; dx=0;   dy=-$n; \
  , d1=right;  d2=left;   dx=$n;  dy=0;   \
  } \
  bspc node --resize $d1 $dx $dy || bspc node --resize $d2 $dx $dy

# set the window state
ctrl + alt + {t,s,f}
	bspc node -t {tiled,pseudo_tiled,floating,fullscreen}
EOL

# Get wallpapers
wget -O ~/.config/wallpaper/wallpaper.jpg https://www.hexxedbitheadz.com/wp-content/uploads/go-x/u/0e8540c4-37b8-4698-b0c4-90bf2a5c8ce5/image.jpg && wget -O ~/.config/wallpaper/lockscreen.png https://www.hexxedbitheadz.com/wp-content/uploads/go-x/u/51ec300d-f912-4605-8bac-8f36bd6e6fea/image.png

# Setting up tools to auto-start:
cat << EOL >> ~/.config/bspwm/bspwmrc
picom --config ~/.config/picom/picom.conf --daemon &
~/.config/polybar/launch.sh
/usr/bin/dunst &

# Setting wallpaper
nitrogen --set-auto ~/.config/wallpaper/wallpaper.jpg &
EOL

# Setting up Terminator:
mkdir ~/.config/terminator && touch ~/.config/terminator/config

cat << EOL > ~/.config/terminator/config
[global_config]
[keybindings]
[profiles]
  [[default]]
    use_system_font=False
    font = GoMono Nerd Font Semi-Bold 18
    foreground_color = "#00ff00"
    borderless = True
    hide_tabbar = True
    show_titlebar = False
    scrollbar_position = hidden
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child]]]
      type = Terminal
      parent = window0
[plugings] 
EOL

# Customizing terminator colors:
cat << EOL >> ~/.zshrc
autoload -U colors && colors

function change_color() {
    if [[ "$?" = 0 ]]; then
    return "green"
  else
    return "red"
  fi
}

# Set terminal prompt to red:
PS1="%F{green}➜%f %b"

# Autoload startx after login:
#if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
#  exec startx
#fi

# Set terminal color to #87d63c:
printf '\033]10;#01cdbd\007'

# Show hidden items in nnn:
export NNN_OPTS="H"

EOL

# Customizing picom settings:
sed -i '/# opacity-rule = \[\]/c\opacity-rule = ["80:class_g = '\''Terminator'\'' && focused", "80:class_g = '\''Terminator'\'' && !focused"];' ~/.config/picom/picom.conf

sed -i 's/shadow-radius = 7;/shadow-radius = 10;/g' ~/.config/picom/picom.conf
sed -i 's/shadow-offset-x = -7;/shadow-offset-x = -5;/g' ~/.config/picom/picom.conf
sed -i 's/shadow-offset-y = -7;/shadow-offset-y = 15;/g' ~/.config/picom/picom.conf
sed -i 's/# shadow-opacity = .75/shadow-opacity = 0.5;/g' ~/.config/picom/picom.conf
sed -i 's/fade-in-step = 0.03;/fade-in-step = 0.07;/g' ~/.config/picom/picom.conf
sed -i 's/fade-out-step = 0.03;/fade-out-step = 0.07;/g' ~/.config/picom/picom.conf

# Getting and setting up nerd-fonts:
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Go-Mono.zip
mkdir -p ~/.local/share/fonts
unzip Go-Mono.zip -d ~/.local/share/fonts/
fc-cache ~/.local/share/fonts

# Customizing polybar:
sed -i 's/background = #282A2E/background = #00/g' ~/.config/polybar/config.ini
sed -i 's/background-alt = #373B41/background-alt = #000000/g' ~/.config/polybar/config.ini
sed -i 's/foreground = #C5C8C6/foreground = #01cdbd/g' ~/.config/polybar/config.ini
sed -i 's/primary = #F0C674/primary = #99ff00/g' ~/.config/polybar/config.ini
sed -i 's/secondary = #8ABEB7/secondary = #000000/g' ~/.config/polybar/config.ini
sed -i '/disabled =/a cancelButton = #01cdbd' ~/.config/polybar/config.ini
sed -i 's/\[bar\/example\]/[bar\/Top]/g' ~/.config/polybar/config.ini
sed -i '/^\[bar\/Top\]$/a bottom=false' ~/.config/polybar/config.ini
sed -i 's/height = 24pt/height = 32pt/' ~/.config/polybar/config.ini
sed -i 's/radius = 6/radius = 0/' ~/.config/polybar/config.ini
sed -i 's/line-size = 3pt/line-size = 2pt/' ~/.config/polybar/config.ini
sed -i 's/border-size = 4pt/border-size = 0pt/' ~/.config/polybar/config.ini
sed -i 's/border-color = #00000000/border-color = #00/' ~/.config/polybar/config.ini
sed -i 's/padding-left = 0/padding-left = 1/g' ~/.config/polybar/config.ini
sed -i 's/padding-right = 2/padding-right = 1/g' ~/.config/polybar/config.ini
sed -i 's/modules-left = xworkspaces xwindow/modules-left = xwindow/g' ~/.config/polybar/config.ini
sed -i 's/font-0 = monospace;2/font-0 = GoMono Nerd Font:style=Bold/' ~/.config/polybar/config.ini
sed -i 's/modules-right = filesystem pulseaudio xkeyboard memory cpu wlan eth date/modules-right = pulseaudio memory cpu wlan eth powermenu/g' ~/.config/polybar/config.ini

cat << 'EOL' >> ~/.config/polybar/config.ini
[bar/Bottom]
bottom=true
width = 100%
height = 18pt
radius = 6
; dpi = 9
background = ${colors.background}
foreground = ${colors.foreground}
padding-left = 1
padding-right = 1
module-margin = 1
font-0 = GoMono Nerd Font:style=Bold
modules-left = bspwm
modules-right = date
cursor-click = pointer
cursor-scroll = ns-resize
enable-ipc = true
; wm-restack = generic
; wm-restack = bspwm
; wm-restack = i3
; override-redirect = true

[module/bspwm]
type = internal/bspwm
; Customize the module as needed
format = <label-state> <label-mode>
; Customize the colors for the active and inactive workspaces
label-focused-foreground=${colors.primary}
label-focused-background=${colors.background}

[module/powermenu]  
type = custom/menu  
expand-right = true  
format-spacing = 1  
label-open = "xxx"  
label-open-foreground = ${colors.primary}  
label-close = xxx cancel  
label-close-foreground = ${colors.foreground}  
label-separator = |  
label-separator-foreground = ${colors.foreground}  
;Powermenu  
menu-0-0 = "Reboot"  
menu-0-0-exec = menu-open-1  
menu-0-0-foreground = ${colors.foreground}  
menu-0-1 = "Power Off"  
menu-0-1-exec = menu-open-2  
menu-0-1-foreground = ${colors.foreground}  
menu-0-2 = "Hibernate"  
menu-0-2-exec = menu-open-3  
menu-0-2-foreground = ${colors.foreground}  
;Reboot  
menu-1-0 = "Reboot"  
menu-1-0-exec = systemctl reboot  
menu-1-0-foreground = ${colors.primary}  
menu-1-1 = "Cancel"  
menu-1-1-exec = menu-open-0  
menu-1-1-foreground = ${colors.cancelButton}  
;Shutdown  
menu-2-0 = "Power off"  
menu-2-0-exec = systemctl poweroff  
menu-2-0-foreground = ${colors.primary}  
menu-2-1 = "Cancel"  
menu-2-1-exec = menu-open-0  
menu-2-1-foreground = ${colors.cancelButton}  
;Hibernate  
menu-3-0 = "Hibernate"  
menu-3-0-exec = systemctl hibernate  
menu-3-0-foreground = ${colors.primary}  
menu-3-1 = "Cancel"  
menu-3-1-exec = menu-open-0  
menu-3-1-foreground = ${colors.cancelButton}
EOL

# Replace the eth0 color:
sed -i 's/label-connected = %{F#F0C674}%ifname%%{F-} %essid% %local_ip%/label-connected = %{F#99ff00}%ifname%%{F-} %essid% %local_ip%/g' ~/.config/polybar/config.ini

sed -i 's/%{F#F0C674}%ifname%%{F-} %local_ip%/%{F#99ff00}%ifname%%{F-} %local_ip%/g' ~/.config/polybar/config.ini

# Replace the date format:
sed -i 's/date = %H:%M/date=%Y-%m-%d %H:%M:%S/g' ~/.config/polybar/config.ini

# Modifying launch.sh to include polybar when booting:
cat << EOF > ~/.config/polybar/launch.sh
#!/usr/bin/env bash

## Launch Top bar
echo "---" | tee -a /tmp/polybar1.log
polybar Top 2>&1 | tee -a /tmp/polybar1.log & disown

echo "Top Bar launched..."

# Launch Bottom bar
echo "---" | tee -a /tmp/polybar1.log
polybar Bottom 2>&1 | tee -a /tmp/polybar1.log & disown

echo "Bottom Bar launched..."
EOF

chmod +x ~/.config/polybar/launch.sh

# Customizing dunstrc notifications:
sed -i '/\[urgency_low\]/,/timeout = 10/ { s/background = "#222222"/background = "#0c75a0"/; s/foreground = "#888888"/foreground = "#000000"/; s/# IMPORTANT: colors have to be defined in quotation marks./# IMPORTANT: colors have to be defined in quotation marks./; s/timeout = 10/timeout = 10/; s/#default_icon = \/path\/to\/icon/#default_icon = \/path\/to\/icon/; s/\[urgency_low\]/\[urgency_low\]\n    frame_color = "#000000"/; }
/\[urgency_normal\]/,/timeout = 10/ { s/background = "#285577"/background = "#87d63c"/; s/foreground = "#ffffff"/foreground = "#000000"/; s/timeout = 10/timeout = 10/; s/#default_icon = \/path\/to\/icon/#default_icon = \/path\/to\/icon/; s/\[urgency_normal\]/\[urgency_normal\]\n    frame_color = "#0c75a0"/; }
/\[urgency_critical\]/,/timeout = 0/ { s/background = "#900000"/background = "#0c75a0"/; s/foreground = "#ffffff"/foreground = "#000000"/; s/frame_color = "#ff0000"/frame_color = "#87d63c"/; s/timeout = 0/timeout = 0/; s/#default_icon = \/path\/to\/icon/#default_icon = \/path\/to\/icon/; }' ~/.config/dunst/dunstrc

sudo apt install kali-linux-headless -y

sudo reboot
