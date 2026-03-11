#!/bin/bash

########################################
# Create Required Folder Structure for Cinnamon Desktop Layout
########################################

echo "Creating required folder structure for Cinnamon layout, taskbar, panel, and settings..."

# Define root folder for the local setup
ROOT_DIR="$HOME/Cinnamon_Config"

# Create the folder structure
mkdir -p "$ROOT_DIR/.config/cinnamon"
mkdir -p "$ROOT_DIR/.local/share/cinnamon/applets"
mkdir -p "$ROOT_DIR/.themes"
mkdir -p "$ROOT_DIR/.icons"
mkdir -p "$ROOT_DIR/.config/dconf"

# Create panel settings and applet configuration files in the appropriate directories
echo "Creating dummy panel settings and applet configuration files..."

# Example panel settings (these would typically be custom settings)
echo '{"panel-layout": "horizontal", "taskbar-size": "medium"}' > "$ROOT_DIR/.config/cinnamon/panel-settings.json"
echo '{"applets": ["clock", "show-desktop", "window-list"]}' > "$ROOT_DIR/.config/cinnamon/applets.json"
echo '{"panel-launchers": ["applications-menu", "show-desktop"]}' > "$ROOT_DIR/.config/cinnamon/panel-launchers.json"

# Create a dummy applet folder with a placeholder applet
mkdir -p "$ROOT_DIR/.local/share/cinnamon/applets/example-applet"
echo "This is a dummy applet configuration." > "$ROOT_DIR/.local/share/cinnamon/applets/example-applet/applet.json"

# Create a dummy theme and icon directory with placeholder files
mkdir -p "$ROOT_DIR/.themes/example-theme"
echo "Example theme file" > "$ROOT_DIR/.themes/example-theme/gtk-3.0/gtk.css"
mkdir -p "$ROOT_DIR/.icons/example-icons"
echo "Example icon" > "$ROOT_DIR/.icons/example-icons/icon.png"

# Create a dummy dconf user settings file
echo "This is a dummy dconf user settings file." > "$ROOT_DIR/.config/dconf/user"

echo "Folder structure and example files created successfully!"

# Output the created folder structure
echo "Created folder structure:"
tree "$ROOT_DIR"
