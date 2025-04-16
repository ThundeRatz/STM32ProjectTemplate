#!/bin/bash

FILES=$(find . \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) \
                -not \( -path "*/cube/*" -o -path "*/build/*" -o -path "*/libs/*" \))

for FILE in $FILES; do
    clang-format -style=file -output-replacements-xml $FILE | grep "<replacement " >/dev/null
    if [ $? -eq 0 ]; then
        echo "Code not properly formatted (File: $FILE). Please run make format." | sed 's/.*/\x1b[31m&\x1b[0m/'
        exit 1
    fi
done

echo "Code properly formatted." | sed 's/.*/\x1b[32m&\x1b[0m/'
