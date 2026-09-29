#!/usr/bin/awk -f
# Parse dotfiles cheatsheet markdown into fzf-friendly TSV rows:
#   display \t run_cmd \t preview_title \t preview_body \t source_file \t line_num

function trim(s) {
    sub(/^[ \t]+/, "", s)
    sub(/[ \t]+$/, "", s)
    return s
}

function strip_ticks(s) {
    gsub(/`/, "", s)
    return trim(s)
}

function dequote(s) {
    gsub(/^`+|`+$/, "", s)
    return trim(s)
}

function lc(s) { return tolower(s) }

function first_token(s,    parts) {
    split(s, parts, "/")
    return trim(parts[1])
}

function looks_like_shell(cmd) {
    if (cmd == "") return 0
    if (cmd ~ /→|prefix|Ctrl|Alt|user\.name/) return 0
    # vi-style key lists (h / j / k / l) or "q or Esc"
    if (cmd ~ /^[a-z]([ \t]*\/[ \t]*[a-z])+$/) return 0
    if (cmd ~ /^q or /) return 0
    return (cmd ~ /^(tmux|git|docker|kubectl|kubectx|kubens|kxd|helm|exec|mise|direnv|notify-send|ssh-keygen|less|bat|fd|fdfind|sl|helm-docs|java|echo|cat|jq|yq)/) \
        || (cmd ~ / /)
}

function extract_shell(s,    cmd, rest) {
    rest = s
    while (match(rest, /`[^`]+`/)) {
        cmd = substr(rest, RSTART + 1, RLENGTH - 2)
        if (looks_like_shell(cmd)) return cmd
        rest = substr(rest, RSTART + RLENGTH)
    }
    if (looks_like_shell(strip_ticks(s))) return strip_ticks(s)
    return ""
}

function is_separator(line) {
    return line ~ /^\|[[:space:]]*[-:][-:|[:space:]]*$/
}

function is_table_row(line) {
    return line ~ /^\|[^|]+\|/
}

function mask_pipes_in_ticks(line,    out, i, c, in_ticks) {
    out = ""
    in_ticks = 0
    for (i = 1; i <= length(line); i++) {
        c = substr(line, i, 1)
        if (c == "`") in_ticks = !in_ticks
        else if (c == "|" && in_ticks) c = "\034"
        out = out c
    }
    return out
}

function split_cells(line, cells,    n, i, masked) {
    masked = mask_pipes_in_ticks(line)
    n = split(masked, raw, "|")
    delete cells
    for (i = 2; i < n; i++) {
        cells[i - 1] = trim(raw[i])
        gsub(/\034/, "|", cells[i - 1])
    }
    return i - 2
}

function set_header(c1, c2, c3, n) {
    header_cols = n
    header1 = lc(dequote(c1))
    header2 = lc(dequote(c2))
    header3 = lc(dequote(c3))
}

function sanitize_field(s) {
    gsub(/\t/, " ", s)
    gsub(/\r/, "", s)
    return s
}

# Dracula-inspired ANSI colors for fzf preview (printf %b)
function color_title(s)    { return "\033[1;35m" s "\033[0m" }
function color_label(s)    { return "\033[0;33m" s "\033[0m" }
function color_cmd(s)      { return "\033[1;32m" s "\033[0m" }
function color_desc(s)     { return "\033[0;37m" s "\033[0m" }

function executes_line(cmd) {
    return color_label("Executes") " → " color_cmd(cmd)
}

function keys_line(keys) {
    return color_label("Keys") " → " color_cmd(keys)
}

function keys_comment(sheet, keys, action) {
    return "# " sheet " keys: " keys "  # " action
}

function format_preview(title, body) {
    if (body == "" || body == title) return color_title(title)
    if (title == "") return body
    return color_title(title) "\\n\\n" body
}

function alias_preview_body(alias_name, cmd, desc,    body) {
    body = ""
    if (cmd != "" && cmd != alias_name) {
        body = executes_line(cmd)
    }
    if (desc != "") {
        if (body != "") body = body "\\n\\n" color_desc(desc)
        else body = color_desc(desc)
    }
    return body
}

function emit(sheet, section, action, run, title, body, file, line,    display, preview) {
    if (action == "") return
    display = sheet ": " section " - " action
    if (title == "") title = (run != "") ? run : action
    if (body == "") body = title
    preview = format_preview(title, body)
    print sanitize_field(display) "\t" sanitize_field(run) "\t" sanitize_field(preview) "\t" file "\t" line
}

function emit_row(file, line,    n, c1, c2, c3, action, run, title, body, keys) {
    n = split_cells($0, cells)
    if (n < 2) return
    c1 = cells[1]
    c2 = cells[2]
    c3 = (n >= 3) ? cells[3] : ""

    action = strip_ticks(c1)
    run = ""
    title = ""
    body = ""

    if (header1 == "action" && header2 == "keys" && header3 == "what it does") {
        action = strip_ticks(c1)
        keys = strip_ticks(c2)
        body = strip_ticks(c3)
        run = extract_shell(c2)
        if (run != "") {
            title = run
            body = color_desc(strip_ticks(c3))
        } else {
            title = action
            if (keys != "" && body != "") {
                body = keys_line(keys) "\\n\\n" color_desc(body)
            } else if (keys != "") {
                body = keys_line(keys)
            } else if (body != "") {
                body = color_desc(body)
            }
            if (keys != "") run = keys_comment(sheet, keys, action)
        }
    } else if (header1 == "keys" && header2 == "action") {
        action = strip_ticks(c2)
        title = action
        body = color_desc(strip_ticks(c1))
        if (action ~ /^[a-zA-Z0-9_.:-]+$/) run = action
    } else if (header1 == "alias" && header2 == "command" && header3 == "what it does") {
        action = strip_ticks(c1)
        cmd = strip_ticks(c2)
        desc = strip_ticks(c3)
        if (action ~ / /) {
            run = extract_shell(c2)
            if (run == "") run = first_token(action)
            title = action
            body = alias_preview_body(action, cmd, desc)
        } else {
            run = first_token(action)
            title = run
            body = alias_preview_body(run, cmd, desc)
        }
    } else if (header1 == "alias" && header2 == "command") {
        action = strip_ticks(c1)
        cmd = strip_ticks(c2)
        desc = (c3 != "") ? strip_ticks(c3) : ""
        if (action ~ / /) {
            run = extract_shell(c2)
            if (run == "") run = first_token(action)
            title = action
            body = alias_preview_body(action, cmd, desc)
        } else {
            run = first_token(action)
            title = run
            body = alias_preview_body(run, cmd, desc)
        }
    } else if (header1 == "command" && header2 == "what it does") {
        action = strip_ticks(c1)
        run = action
        title = action
        body = color_desc(strip_ticks(c2))
    } else if (header1 == "function" && header2 == "what it does") {
        action = strip_ticks(c1)
        run = action
        title = action
        body = color_desc(strip_ticks(c2))
    } else if (header1 == "alias" && header2 == "action") {
        action = strip_ticks(c1)
        title = first_token(action)
        body = color_desc(strip_ticks(c2))
        run = extract_shell(c2)
        if (run == "" && action ~ /^[a-zA-Z0-9_.:-]+$/) run = first_token(action)
    } else if (header1 == "command" && header2 == "action") {
        action = strip_ticks(c1)
        run = action
        title = action
        body = color_desc(strip_ticks(c2))
    } else if (header1 == "function" && header2 == "action") {
        action = strip_ticks(c1)
        run = action
        title = action
        body = color_desc(strip_ticks(c2))
    } else if (header1 == "action" && header2 == "keys") {
        action = strip_ticks(c1)
        keys = strip_ticks(c2)
        title = action
        body = color_desc(keys)
        run = extract_shell(c2)
        if (run == "" && keys != "") run = keys_comment(sheet, keys, action)
    } else if (header1 == "task" && header2 == "command" && header3 == "what it does") {
        action = strip_ticks(c1)
        run = strip_ticks(c2)
        title = run
        body = color_desc(strip_ticks(c3))
    } else if (header1 == "task" && header2 == "command") {
        action = strip_ticks(c1)
        run = strip_ticks(c2)
        title = run
        body = color_desc(action)
    } else if (header1 == "plugin" || header1 == "behavior" || header1 == "setting") {
        action = strip_ticks(c1)
        title = action
        body = color_desc(strip_ticks(c2))
    } else {
        title = action
        body = color_desc(strip_ticks(c2))
        run = extract_shell(c2)
        if (run == "" && action ~ /^[a-zA-Z0-9_.:-]+$/) run = action
    }

    emit(sheet, section, action, run, title, body, file, line)
}

BEGIN {
    section = "General"
    in_table = 0
    pending_header = 0
    in_code = 0
    code_section = 0
}

/^## / {
    section = trim(substr($0, 4))
    in_table = 0
    pending_header = 0
    in_code = 0
    code_section = (tolower(section) ~ /(useful commands|shell commands)/)
    next
}

/^### / {
    in_table = 0
    pending_header = 0
    next
}

/^```bash/ {
    in_code = 1
    next
}

/^```/ {
    in_code = 0
    next
}

in_code {
    if (!code_section) next
    line = $0
    body = ""
    if (match(line, /[ \t]+#/)) {
        body = trim(substr(line, RSTART + RLENGTH))
        line = trim(substr(line, 1, RSTART - 1))
    } else {
        line = trim(line)
    }
    if (line == "" || line ~ /^#/) next
    if (body == "") body = line
    emit(sheet, section, line, line, line, color_desc(body), file, FNR)
    next
}

{
    if (!is_table_row($0)) {
        if ($0 !~ /^[[:space:]]*$/) {
            in_table = 0
            pending_header = 0
        }
        next
    }

    if (is_separator($0)) {
        in_table = 1
        pending_header = 0
        next
    }

    if (!in_table && !pending_header) {
        n = split_cells($0, cells)
        if (n >= 2) {
            set_header(cells[1], cells[2], (n >= 3) ? cells[3] : "", n)
            pending_header = 1
        }
        next
    }

    if (in_table) {
        emit_row(file, FNR)
    }
}
