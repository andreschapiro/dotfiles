#!/usr/bin/env bash

# Network configuration script
# Handles Wake on LAN and other network settings

# Enable Wake on LAN for all network interfaces
enable_wake_on_lan() {
  echo "==> Configuring Wake on LAN"
  
  # Install ethtool if not present
  if ! command -v ethtool &>/dev/null; then
    echo "  Installing ethtool..."
    if command -v pacman &>/dev/null; then
      run "sudo pacman -S --noconfirm ethtool"
    elif command -v apt-get &>/dev/null; then
      run "sudo apt-get install -y ethtool"
    else
      echo "  Error: Package manager not supported"
      return 1
    fi
  fi
  
  # Get all network interfaces (exclude loopback)
  local interfaces
  interfaces=$(ip link show | awk -F': ' '/^[0-9]+:/ {print $2}' | grep -v '^lo$')
  
  if [[ -z "$interfaces" ]]; then
    echo "  Warning: No network interfaces found"
    return 1
  fi
  
  echo "  Found network interfaces:"
  echo "$interfaces" | sed 's/^/    /'
  echo ""
  
  # Enable WoL for each interface
  for iface in $interfaces; do
    # Check if interface supports Wake on LAN
    if ! ethtool "$iface" &>/dev/null; then
      echo "  Skipping $iface (not accessible or virtual interface)"
      continue
    fi
    
    # Check if WoL is supported
    local wol_support
    wol_support=$(ethtool "$iface" 2>/dev/null | grep -i "Supports Wake-on" | awk '{print $NF}')
    
    if [[ -z "$wol_support" || "$wol_support" == "d" ]]; then
      echo "  Skipping $iface (does not support Wake on LAN)"
      continue
    fi
    
    echo "  Enabling Wake on LAN for $iface..."
    run "sudo ethtool -s $iface wol g"
    
    # Verify the setting
    local current_wol
    current_wol=$(ethtool "$iface" 2>/dev/null | grep -i "Wake-on:" | awk '{print $NF}')
    
    if [[ "$current_wol" == "g" ]]; then
      echo "    ✓ Wake on LAN enabled (magic packet mode)"
    else
      echo "    ✗ Failed to enable Wake on LAN (current: $current_wol)"
    fi
  done
  
  # Create systemd service to enable WoL on boot
  create_wol_service
  
  echo ""
  echo "  Wake on LAN configuration complete"
}

# Create systemd service to persist WoL settings across reboots
create_wol_service() {
  local service_file="/etc/systemd/system/wol@.service"
  
  echo "  Creating systemd service for persistent WoL..."
  
  # Create the service file
  run "sudo tee $service_file > /dev/null << 'EOF'
[Unit]
Description=Wake on LAN for %i
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s %i wol g

[Install]
WantedBy=multi-user.target
EOF"
  
  # Enable the service for all network interfaces
  local interfaces
  interfaces=$(ip link show | awk -F': ' '/^[0-9]+:/ {print $2}' | grep -v '^lo$')
  
  for iface in $interfaces; do
    # Check if interface supports WoL
    if ! ethtool "$iface" &>/dev/null 2>&1; then
      continue
    fi
    
    local wol_support
    wol_support=$(ethtool "$iface" 2>/dev/null | grep -i "Supports Wake-on" | awk '{print $NF}')
    
    if [[ -n "$wol_support" && "$wol_support" != "d" ]]; then
      echo "    Enabling wol@$iface.service..."
      run "sudo systemctl enable wol@$iface.service"
    fi
  done
  
  echo "    ✓ Systemd service created and enabled"
}

# Show current Wake on LAN status
show_wol_status() {
  echo "==> Wake on LAN Status"
  echo ""
  
  local interfaces
  interfaces=$(ip link show | awk -F': ' '/^[0-9]+:/ {print $2}' | grep -v '^lo$')
  
  for iface in $interfaces; do
    if ! ethtool "$iface" &>/dev/null 2>&1; then
      continue
    fi
    
    echo "  Interface: $iface"
    ethtool "$iface" 2>/dev/null | grep -E "Supports Wake-on:|Wake-on:" | sed 's/^/    /'
    echo ""
  done
}
