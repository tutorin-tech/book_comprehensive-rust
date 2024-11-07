#!/usr/bin/env bash
set -Eeuo pipefail

# Usage: build.sh <book-lang> <dest-dir>

book_lang=${1:?"Usage: $0 <book-lang> <dest-dir>"}
dest_dir=${2:?"Usage: $0 <book-lang> <dest-dir>"}

if [ "$book_lang" = "en" ]; then
    echo "::group::Building English course"
else
    echo "::group::Building $book_lang translation"

    # Set language and adjust site URL. Clear the redirects since they are
    # in sync with the source files, not the translation.
    export MDBOOK_BOOK__LANGUAGE=$book_lang
    export MDBOOK_OUTPUT__HTML__SITE_URL=/comprehensive-rust/$book_lang/
    export MDBOOK_OUTPUT__HTML__REDIRECT='{}'

    # Include language-specific Pandoc configuration
    if [ -f ".github/pandoc/$book_lang.yaml" ]; then
        export MDBOOK_OUTPUT__PANDOC__PROFILE__PDF__DEFAULTS=".github/pandoc/$book_lang.yaml"
    fi
fi

# Enable mdbook-pandoc to build PDF version of the course
export MDBOOK_OUTPUT__PANDOC__DISABLED=false

mdbook build -d "$dest_dir"

# Disable the redbox button in built versions of the course
echo '// Disabled in published builds, see build.sh' > "${dest_dir}/html/theme/redbox.js"

mv "$dest_dir/pandoc/pdf/comprehensive-rust.pdf" "$dest_dir/html/"
(cd "$dest_dir/exerciser" && zip --recurse-paths ../html/comprehensive-rust-exercises.zip comprehensive-rust-exercises/)

echo "::endgroup::"
