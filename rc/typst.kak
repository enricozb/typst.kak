# Detection

hook global BufCreate .*[.](typ) %{
    set-option buffer filetype typst
}

# Initialization

hook -group typst-highlight global WinSetOption filetype=typst %{
    require-module typst

    add-highlighter window/typst ref typst/content

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/typst
        set-option -remove buffer extra_word_chars '-'
    }

    set-option -add buffer extra_word_chars '-'
}

provide-module typst %§

# Highlighters

add-highlighter shared/typst group

# typst has three modes, code, content, and math.
# the default mode is content
add-highlighter shared/typst/content regions
add-highlighter shared/typst/code regions
add-highlighter shared/typst/math regions

# --- content ---
add-highlighter shared/typst/content/regex default-region group
add-highlighter shared/typst/content/regex/label regex '<[a-zA-Z0-9:_-]+>' 0:header
add-highlighter shared/typst/content/regex/ref regex '@[a-zA-Z0-9:_-]+' 0:header
add-highlighter shared/typst/content/heading region '^\h*=+' '$' fill header
add-highlighter shared/typst/content/block-comment region -recurse '/\*' '/\*' '\*/' fill comment
add-highlighter shared/typst/content/line-default region '//' '$' fill comment
add-highlighter shared/typst/content/strong region '\*' '\*' fill +b
add-highlighter shared/typst/content/emphasis region '_' '_' fill +i
add-highlighter shared/typst/content/code-( region -recurse '\(' '\(' '\)' ref typst/code
add-highlighter shared/typst/content/code-{ region -recurse '\{' '\{' '\}' ref typst/code
add-highlighter shared/typst/content/import region '#import' '\n' ref typst/code
add-highlighter shared/typst/content/inline-code region '#' '(?![\w.-])' ref typst/code
add-highlighter shared/typst/content/math region '\$' '(?<!\\)\$' ref typst/math

# --- code ---
add-highlighter shared/typst/code/regex default-region group
add-highlighter shared/typst/code/regex/hash regex '#[\w.-]+' 0:meta
add-highlighter shared/typst/code/regex/keyword regex (?!-)(import|show|for|let|if||else)(?!-) 1:keyword
add-highlighter shared/typst/code/regex/value regex \b(\d+(em|deg|pt|px)?|true|false|none)\b 1:value
add-highlighter shared/typst/code/string region '"' '"' fill string
add-highlighter shared/typst/code/block-comment region -recurse '/\*' '/\*' '\*/' fill comment
add-highlighter shared/typst/code/line-default region '//' '$' fill comment
add-highlighter shared/typst/code/content region -recurse '\[' '\[' '\]' ref typst/content
add-highlighter shared/typst/code/math region '\$' '(?<!\\)\$' ref typst/math

# --- math ---
add-highlighter shared/typst/math/default default-region fill attribute

# Commands

define-command -hidden typst-on-new-line %<
    evaluate-commands -draft -itersel %<
        # Preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # Cleanup trailing whitespaces from previous line
        try %{ execute-keys -draft k x s \h+$ <ret> d }
    >
>

§
