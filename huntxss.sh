#!/bin/bash

GREEN="\033[92m"
RED="\033[91m"
BLUE="\033[94m"
YELLOW="\033[93m"
RESET="\033[0m"

print_info() { echo -e "${BLUE}[i]${RESET} $1"; }
print_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
print_error() { echo -e "${RED}[!]${RESET} $1"; }
print_warning() { echo -e "${YELLOW}[⚠]${RESET} $1"; }

run_command() {
    local command="$1"
    local description="$2"
    local verbose="$3"
    
    if [ "$verbose" = true ]; then
        print_info "Running: $command"
    fi
    print_info "$description"
    
    if [ "$verbose" = true ]; then
        if ! output=$(eval "$command" 2>&1); then
            print_error "Failed: $description\n$output"
            return 1
        fi
        print_info "Output: $output"
    else
        if ! output=$(eval "$command" 2>&1); then
            print_error "Failed: $description\n$output"
            return 1
        fi
    fi
}

main() {
    local domain=""
    local domain_list=""
    local threads=50
    local output_dir="results"
    local verbose=false
    local ports="80,443,8080,8000,8888"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--domain)
                domain="$2"
                shift 2
                ;;
            -dL|--domain-list)
                domain_list="$2"
                shift 2
                ;;
            -t|--threads)
                threads="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                print_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
    
    if [ -z "$domain" ] && [ -z "$domain_list" ]; then
        print_error "Either -d or -dL must be specified"
        exit 1
    fi
    
    mkdir -p "$output_dir"
    
    local subdomains_file="$output_dir/subdomains.txt"
    local live_subdomains_file="$output_dir/live_subdomains.txt"
    local passive_urls_file="$output_dir/passive_urls.txt"
    local xss_output_file="$output_dir/xss_results.txt"
    
    if [ -n "$domain_list" ]; then
        run_command "subfinder -dL \"$domain_list\" -recursive -all -o \"$subdomains_file\"" \
                   "Running Subfinder for subdomain enumeration" "$verbose" || exit 1
    else
        # For single domain, skip subfinder and create subdomains file with just the domain
        echo "$domain" > "$subdomains_file"
    fi
    
    local httpx_input
    if [ -n "$domain_list" ]; then
        httpx_input="cat \"$subdomains_file\""
    else
        httpx_input="echo \"$domain\""
    fi
    
    run_command "$httpx_input | httpx-toolkit -ports \"$ports\" -threads \"$threads\" -o \"$live_subdomains_file\"" \
               "Probing live hosts with HTTPX" "$verbose" || exit 1
    
    run_command "cat \"$live_subdomains_file\" | gau --threads \"$threads\" --o \"$passive_urls_file\"" \
               "Collecting passive URLs with gau" "$verbose" || exit 1
    
    run_command "cat \"$passive_urls_file\" | gf xss | uro | Gxss -c 100 | kxss | tee \"$xss_output_file\"" \
               "Searching for XSS vulnerabilities" "$verbose" || exit 1
    
    print_success "\nScan completed successfully!"
    print_success "Results saved in: $output_dir"
}

trap 'print_error "\nScript interrupted by user"; exit 1' INT

main "$@"
