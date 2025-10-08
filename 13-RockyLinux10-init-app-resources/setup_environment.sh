#!/usr/bin/env bash

# Enable strict error checking
set -euo pipefail

# --------------------------
# Configuration Section
# --------------------------
SCRIPT_NAME="setup_environment.sh"
SCRIPT_VERSION="1.0.0"
ENV_MARKER="# AUTO-GENERATED ENV VARS - DO NOT EDIT MANUALLY"

mkdir -pv /appvol/ilovemyhome/{bin,config,libs,data,install,logs,runtime,tmp,download}

ENV_VARS=(
    "APP_ROOT=/appvol/ilovemyhome"
    "APP_BIN=\$APP_ROOT/bin"
    "APP_LIBS=\$APP_ROOT/libs"
    "APP_CONFIG_ROOT=\$APP_ROOT/config"
    "APP_DATA_ROOT=\$APP_ROOT/data"
    "APP_INSTALL_ROOT=\$APP_ROOT/runtime"
    "APP_LOG_ROOT=\$APP_ROOT/logs"
    "APP_RUNTIME_ROOT=\$APP_ROOT/runtime"
    "APP_TEMP_ROOT=\$APP_ROOT/tmp"
    "APP_DOWNLOAD_ROOT=\$APP_ROOT/download"
    "PATH=\${PATH}:\$APP_ROOT/bin"
)


# Log configuration
LOG_DIR="/appvol/ilovemyhome/logs/${SCRIPT_NAME%.*}"  # Log directory
LOG_FILE="${LOG_DIR}/$(date +%Y%m%d).log"  # Daily log file
MAX_LOG_DAYS=7  # Keep logs for 7 days
LOG_ROTATE_SIZE=$((1024 * 1024))  # 1MB per log file

# --------------------------
# Options and Variable Initialization
# --------------------------
FORCE=0           # Force update without confirmation
SILENT=0          # Silent mode, only output errors
SYSTEM_WIDE=0     # System-wide configuration (all users)
VERBOSE=0         # Verbose output mode
SHOW_HELP=0       # Show help information
SHOW_VERSION=0    # Show version information
START_TIME=$(date +%s)  # Script start timestamp

# --------------------------
# Error Handling & Traps
# --------------------------
# Cleanup function for script exit
cleanup() {
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))

    if [ $exit_code -eq 0 ]; then
        log_info "Script completed successfully (duration: ${duration}s)"
    else
        log_error "Script exited with error code ${exit_code} (duration: ${duration}s)"
    fi
}

# Trap for error, exit and cleanup
trap 'cleanup' EXIT
trap 'log_error "Critical error at line $LINENO - aborting"; exit 1' ERR

# --------------------------
# Logging Functions (with file output)
# --------------------------
# Color codes (console only)
__CN='\033[0m';__CR='\033[0;31m';__CG='\033[0;32m';
__CY='\033[0;33m';__CB='\033[0;34m';__CM='\033[0;35m';

# Ensure log directory exists
init_logging() {
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR" || {
            echo "[$(date '+%F %T')] ERROR: Failed to create log directory $LOG_DIR" >&2
            exit 1
        }
    fi

    # Rotate log if exceeding size limit
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -ge $LOG_ROTATE_SIZE ]; then
        local rotate_suffix=$(date +%H%M%S)
        mv "$LOG_FILE" "${LOG_FILE}.${rotate_suffix}" || log_warn "Failed to rotate log file"
    fi

    # Cleanup old logs
    find "$LOG_DIR" -name "$(basename "$LOG_FILE")*" -type f -mtime +$MAX_LOG_DAYS -delete || \
        log_warn "Failed to clean up old log files"
}

# Base log function (handles both console and file output)
log_base() {
    local level=$1
    local color=$2
    local message=$3
    local timestamp=$(date '+%F %T')
    local log_line="[$timestamp] [$level] $message"

    # Output to console with color if not silent
    if [ $SILENT -eq 0 ]; then
        printf "${color}${log_line}${__CN}\n"
    fi

    # Output to log file (without color codes)
    echo "$log_line" >> "$LOG_FILE"
}

# Log level wrappers
log_info()  { log_base "INFO"  "$__CG" "$*"; }
log_warn()  { log_base "WARN"  "$__CY" "$*"; }
log_error() { log_base "ERROR" "$__CR" "$*" >&2; }  # Also output to stderr
log_debug() {
    if [ $VERBOSE -eq 1 ]; then
        log_base "DEBUG" "$__CB" "$*"
    fi
}
log_hint()  { log_base "HINT"  "$__CM" "$*"; }
log_line()  {
    local msg="[$*] ==========================================="
    log_base "LINE" "$__CM" "$msg"
}

# --------------------------
# Utility Functions
# --------------------------
# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "Required command not found: $1"
        log_hint "Please install $1 before running this script"
        exit 1
    }
}

# Retry a command with backoff
retry_command() {
    local retries=3
    local delay=2
    local command="$*"
    local attempt=1

    while [ $attempt -le $retries ]; do
        if eval "$command"; then
            return 0
        fi
        log_warn "Command failed (attempt $attempt/$retries): $command"
        if [ $attempt -lt $retries ]; then
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff
        fi
        attempt=$((attempt + 1))
    done

    log_error "Command failed after $retries attempts: $command"
    return 1
}

# --------------------------
# Core Function Definitions
# --------------------------

# Show help information
print_help() {
    cat << EOF
Usage: ${0##*/} [options]

Script to set application environment variables with support for temporary settings and permanent saving

Options:
  -f, --force        Force update configuration without user confirmation
  -s, --silent       Silent mode - only output error messages
  -v, --verbose      Verbose output mode - show detailed execution steps
  -i, --system       System-wide configuration (applies to all users, requires root)
  -h, --help         Show this help message and exit
  --version          Show version information and exit

Examples:
  ${0##*/}                  # Run interactively (current user configuration)
  ${0##*/} -f               # Force update without confirmation
  sudo ${0##*/} -i -f       # System-wide configuration with force update
EOF
}

# Show version information
print_version() {
    echo "${SCRIPT_NAME} v${SCRIPT_VERSION}"
}

# Temporarily set environment variables (current terminal only)
set_temp_env_vars() {
    log_line "SET_TEMP_ENV_VARS"
    log_info "Starting temporary environment variable setup..."
    [ $VERBOSE -eq 1 ] && echo "-------------------------"

    for var in "${ENV_VARS[@]}"; do
        # Extract variable name (before equals sign)
        var_name=$(echo "$var" | cut -d'=' -f1)
        log_debug "Processing variable: $var_name"

        # First expand the variable content before exporting
        local var_expanded
        var_expanded=$(eval echo "$var")
        log_debug "Expanded value: $var_expanded"

        # Export variable with error checking
        if ! export "$var_expanded"; then
            log_error "Failed to export variable: $var_expanded"
            log_hint "Check if variable definition is valid: $var"
            return 1
        fi

        # Verify variable was set
        local var_value
        var_value=$(eval echo "\${$var_name:-}")
        if [ -z "$var_value" ]; then
            log_error "Variable $var_name is empty after export"
            return 1
        fi
        log_info "Successfully set: $var_name=$var_value"
    done

    log_info "Temporary environment variables setup completed"
}

# Permanently save environment variables to configuration file
# shellcheck disable=SC2120
save_env_vars_permanently() {
    log_line "SAVE_ENV_VARS_PERMANENTLY"
    local config_file

    # Determine configuration file path
    if [ $SYSTEM_WIDE -eq 1 ]; then
        config_file="/etc/profile.d/app_env.sh"
        log_debug "System-wide configuration target: $config_file"

        # Verify root privileges
        if [ "$(id -u)" -ne 0 ]; then
            log_error "System-wide configuration requires root privileges"
            log_hint "Run with: sudo $0 $*"
            return 1
        fi
    else
        # User-specific configuration
        if [ -n "${ZSH_VERSION:-}" ]; then
            config_file="$HOME/.zshrc"
        else
            config_file="$HOME/.bashrc"
        fi
        log_debug "User configuration target: $config_file"
    fi

    # Check configuration file accessibility
    if [ -f "$config_file" ] && [ ! -w "$config_file" ]; then
        log_error "No write permission for configuration file: $config_file"
        log_hint "Check file permissions or run with appropriate privileges"
        return 1
    fi

    # Create file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        log_debug "Creating new configuration file: $config_file"
        retry_command "touch \"$config_file\"" || {
            log_error "Failed to create configuration file: $config_file"
            return 1
        }
    fi

    # Remove existing configuration block if present
    if grep -qxF "$ENV_MARKER" "$config_file"; then
        log_info "Updating existing configuration block in $config_file"
        # Use sed with backup (handles different sed implementations)
        if sed --version >/dev/null 2>&1; then
            # GNU sed
            retry_command "sed -i.bak \"/$ENV_MARKER/,/^$/d\" \"$config_file\"" || {
                log_error "Failed to update configuration with GNU sed"
                return 1
            }
        else
            # BSD sed (macOS)
            retry_command "sed -i '' \"/$ENV_MARKER/,/^$/d\" \"$config_file\"" || {
                log_error "Failed to update configuration with BSD sed"
                return 1
            }
        fi

        # Cleanup backup unless verbose mode
        if [ $VERBOSE -eq 0 ] && [ -f "${config_file}.bak" ]; then
            rm -f "${config_file}.bak" || log_warn "Failed to remove backup file ${config_file}.bak"
        fi
    else
        log_info "Adding new configuration block to $config_file"
    fi

    # Append new environment variables
    {
        echo -e "\n$ENV_MARKER"
        echo "# Last updated: $(date '+%F %T')"
        echo "# Generated by ${SCRIPT_NAME} v${SCRIPT_VERSION}"
        for var in "${ENV_VARS[@]}"; do
            echo "export $var"
        done
        echo ""  # Empty line as block terminator
    } >> "$config_file" || {
        log_error "Failed to write to configuration file: $config_file"
        return 1
    }

    log_info "Successfully updated environment variables in $config_file"
    log_hint "Apply changes immediately with: source $config_file"
}

# Parse command line arguments
parse_arguments() {
    log_line "PARSE_ARGUMENTS"
    log_debug "Raw arguments: $*"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                FORCE=1
                log_debug "Enabled force mode"
                shift
                ;;
            -s|--silent)
                SILENT=1
                log_debug "Enabled silent mode"
                shift
                ;;
            -v|--verbose)
                VERBOSE=1
                log_debug "Enabled verbose mode"
                shift
                ;;
            -i|--system)
                SYSTEM_WIDE=1
                log_debug "Enabled system-wide configuration"
                shift
                ;;
            -h|--help)
                SHOW_HELP=1
                shift
                ;;
            --version)
                SHOW_VERSION=1
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
}

# Main program logic
main() {
    # Initialize logging system first
    init_logging

    # Log script startup info
    log_line "SCRIPT_START"
    log_info "${SCRIPT_NAME} v${SCRIPT_VERSION} started"
    log_debug "Execution user: $(id -un) (UID: $(id -u))"
    log_debug "Execution directory: $(pwd)"
    log_debug "Command line: $0 $*"

    # Check required commands
    command_exists "grep"
    command_exists "sed"
    command_exists "date"

    # Parse arguments
    parse_arguments "$@"

    # Show help/version if requested
    if [ $SHOW_HELP -eq 1 ]; then
        print_help
        exit 0
    fi

    if [ $SHOW_VERSION -eq 1 ]; then
        print_version
        exit 0
    fi

    # Validate environment (check APP_HOME parent directory)
    local app_home_parent=$(dirname "${ENV_VARS[0]#*=}")
    if [ ! -d "$app_home_parent" ] && [ ! -w "$(dirname "$app_home_parent")" ]; then
        log_warn "Parent directory for APP_HOME does not exist: $app_home_parent"
        log_hint "You may need to create it with: mkdir -p $app_home_parent"
    fi

    # Set temporary variables
    if ! set_temp_env_vars; then
        log_error "Failed to set temporary environment variables"
        exit 1
    fi

    # Handle permanent saving
    if [ $FORCE -eq 1 ]; then
        log_debug "Force mode: saving permanently without confirmation"
        if ! save_env_vars_permanently; then
            log_error "Failed to save environment variables permanently"
            exit 1
        fi
    else
        # Prompt user unless silent mode
        if [ $SILENT -eq 0 ]; then
            local scope=$( [ $SYSTEM_WIDE -eq 1 ] && echo "system-wide" || echo "user-specific" )
            read -p "Save environment variables permanently to $scope configuration? (y/n) " -n 1 -r
            echo  # New line

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if ! save_env_vars_permanently; then
                    log_error "Failed to save environment variables permanently"
                    exit 1
                fi
            else
                log_info "Skipping permanent save - changes valid only for current session"
            fi
        else
            log_info "Silent mode: skipping permanent save"
        fi
    fi

    log_line "SCRIPT_COMPLETE"
}

# Start main execution
main "$@"
