#!/bin/bash
# CLI for Memory Evolution Integration
# Usage: ./evo.sh <command> [options]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/integrate.sh"

case "${1:-}" in
    log)
        shift
        evolution_log "$@"
        ;;
    chain)
        evolution_chain_build
        ;;
    track)
        shift
        effect_track "$@"
        ;;
    scoreboard)
        effect_scoreboard
        ;;
    status)
        evolution_status
        ;;
    help|--help|-h)
        echo "🧬 Memory Evolution CLI"
        echo "======================="
        echo ""
        echo "Commands:"
        echo "  log --source <s> --track <t> --title <title> --insight <i> --action <a>"
        echo "      Record an evolution event"
        echo ""
        echo "  chain"
        echo "      Build anti-repeat chains from log"
        echo ""
        echo "  track --capability <name> --time_saved <min> --repeat_avoided <bool> --outcome <result>"
        echo "      Track effect of a capability"
        echo ""
        echo "  scoreboard"
        echo "      Show effect scoreboard"
        echo ""
        echo "  status"
        echo "      Show current status"
        ;;
    *)
        evolution_status
        ;;
esac
