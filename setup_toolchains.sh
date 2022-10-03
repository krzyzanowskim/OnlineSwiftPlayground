if ! command -v swiftenv &> /dev/null; then
    echo '`swiftenv` not found. Download from https://github.com/kylef/swiftenv.git' >&2
    exit 127
fi

swiftenv install 5.7
swiftenv install 5.6.3
