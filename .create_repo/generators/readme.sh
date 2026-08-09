#!/usr/bin/env bash
# .create_repo/generators/readme.sh
# README needs conditional content per build system, so it's assembled
# directly rather than through a single static .tmpl file.

generate_readme() {
  echo "==> README.md"

  local build_instructions=""
  case "$BUILD" in
    make)
      build_instructions=$(cat <<'EOF'
```sh
make          # build
make run      # build and run
make debug    # build with -g -O0
make asan     # build with ASan/UBSan
make clean
```
EOF
)
      ;;
    cmake)
      build_instructions=$(cat <<'EOF'
```sh
cmake -B build
cmake --build build
./build/PROJECT_NAME_PLACEHOLDER
```
EOF
)
      ;;
    posix-build.sh)
      build_instructions=$(cat <<'EOF'
```sh
./build.sh          # build
./build.sh debug    # build with -g -O0
./build.sh asan     # build with ASan/UBSan
./build.sh clean
```
EOF
)
      ;;
    configure)
      build_instructions=$(cat <<'EOF'
```sh
./configure                # probe for a compiler, write config.mk
./configure --prefix=/usr  # or any other prefix
./configure --enable-debug
./configure --enable-asan
make
make install                # respects PREFIX / DESTDIR
```
EOF
)
      ;;
  esac
  build_instructions="${build_instructions//PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME}"

  local license_line=""
  [ "$LICENSE" != "None" ] && license_line="Licensed under $LICENSE - see [LICENSE](LICENSE)."

  cat > "README.md" <<EOF
# ${PROJECT_NAME}

Short description of what ${PROJECT_NAME} does.

## Requirements

- A ${LANG} compiler with ${STD} support
$( [ "$BUILD" = "cmake" ] && echo "- CMake >= 3.15" )

## Build

${build_instructions}

## Formatting & linting

\`\`\`sh
scripts/format.sh   # clang-format -i, or: $( [ "$BUILD" = "make" ] || [ "$BUILD" = "configure" ] && echo "make format" || echo "./build.sh format / cmake --build build --target format" )
scripts/lint.sh      # clang-tidy,     or: $( [ "$BUILD" = "make" ] || [ "$BUILD" = "configure" ] && echo "make lint" || echo "./build.sh lint / cmake --build build --target lint" )
\`\`\`

## Project layout

\`\`\`
src/        source files
include/    public headers
examples/   example programs
tests/      unit tests
docs/       documentation
\`\`\`

## License

${license_line}
EOF
  echo "  created README.md"
}
