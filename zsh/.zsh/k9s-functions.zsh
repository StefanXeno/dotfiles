# shellcheck shell=bash
#
# K9S Node Shell Feature Gate Management
#
# This script provides two utility functions to easily enable and disable
# the K9S Node Shell feature gate environment variable.
#
# Functions:
#   k9s-node-shell-on  - Sets K9S_FEATURE_GATE_NODE_SHELL=true
#   k9s-node-shell-off - Unsets K9S_FEATURE_GATE_NODE_SHELL
#
# Usage:
#   Add these functions to your ~/.zshrc or source this file directly
#   Then use: k9s-node-shell-on / k9s-node-shell-off
#

# Function to enable the K9S Node Shell Feature Gate
k9s-node-shell-on() {
    export K9S_FEATURE_GATE_NODE_SHELL=true
    echo "✅ K9S Node Shell Feature Gate enabled"
    echo "   K9S_FEATURE_GATE_NODE_SHELL=$K9S_FEATURE_GATE_NODE_SHELL"
}

# Function to disable the K9S Node Shell Feature Gate
k9s-node-shell-off() {
    unset K9S_FEATURE_GATE_NODE_SHELL
    echo "❌ K9S Node Shell Feature Gate disabled"
    echo "   K9S_FEATURE_GATE_NODE_SHELL is now unset"
}
