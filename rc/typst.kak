# ================================= detection ==================================

hook global BufCreate .*[.](typ) %{
  set-option buffer filetype typst
}


# =============================== initialization ===============================

hook -group typst-highlight global WinSetOption filetype=typst %{
  require-module typst

  add-highlighter window/typst ref typst/content
  set-option -add buffer extra_word_chars '-'
  map buffer normal $ i$<esc>Ha$<esc> # surrounc with $
  hook -group typst-load-languages window NormalIdle .* %{ typst-load-languages }
  hook -group typst-load-languages window InsertIdle .* %{ typst-load-languages }

  # undo typst initialization on filetype change
  hook -once -always window WinSetOption filetype=.* %{
    remove-highlighter window/typst
    set-option -remove buffer extra_word_chars '-'
    unmap buffer normal $ i$<esc>Ha`<esc>
    remove-hooks window typst-load-languages
  }
}


# ================================= definition =================================

provide-module typst %§


# ================================ highlighters ================================

add-highlighter shared/typst group

# typst has three modes, code, content, and math. the default mode is content
add-highlighter shared/typst/content regions
add-highlighter shared/typst/code regions
add-highlighter shared/typst/math regions

# ---------------------------------- content -----------------------------------
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
add-highlighter shared/typst/content/fence region ``` ``` ref typst/fence

# ------------------------------------ code ------------------------------------
add-highlighter shared/typst/code/regex default-region group
add-highlighter shared/typst/code/regex/hash regex '#[\w.-]+' 0:meta
add-highlighter shared/typst/code/regex/keyword regex (?!-)(import|show|for|let|if||else)(?!-) 1:keyword
add-highlighter shared/typst/code/regex/value regex \b(\d+(em|deg|pt|px)?|true|false|none)\b 1:value
add-highlighter shared/typst/code/string region '"' '"' fill string
add-highlighter shared/typst/code/block-comment region -recurse '/\*' '/\*' '\*/' fill comment
add-highlighter shared/typst/code/line-default region '//' '$' fill comment
add-highlighter shared/typst/code/content region -recurse '\[' '\[' '\]' ref typst/content
add-highlighter shared/typst/code/math region '\$' '(?<!\\)\$' ref typst/math
add-highlighter shared/typst/code/fence region ``` ``` ref typst/fence

# ------------------------------------ math ------------------------------------
add-highlighter shared/typst/math/default default-region fill attribute

# ----------------------------------- fence -----------------------------------
add-highlighter shared/typst/fence regions
add-highlighter shared/typst/fence/ default-region fill meta

define-command -hidden typst-load-languages -docstring 'load language modules for code fences' %{
  evaluate-commands -draft %{
    try %{
      execute-keys '%1s```([a-z]+)\s<ret>'
      evaluate-commands -itersel %{
        try %{
          require-module %val{selection}

          add-highlighter "shared/typst/fence/%val{selection}" region "```%val{selection}\K" (?=```) ref %val{selection}
        }
      }
    }
  }
}

# ================================== commands ==================================

define-command -hidden typst-on-new-line %{
  evaluate-commands -draft -itersel %{
    # Preserve previous line indent
    try %{ execute-keys -draft <semicolon> K <a-&> }
    # Cleanup trailing whitespaces from previous line
    try %{ execute-keys -draft k x s \h+$ <ret> d }
  }
}

§
