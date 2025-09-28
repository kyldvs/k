set fallback := true
set shell := ["bash", "-uc"]
set ignore-comments

@_default:
  just --list

@help:
  just --list

mod hooks "tasks/hooks"
mod bootstrap "tasks/bootstrap"
mod test "tasks/test"

home_dir := env_var('HOME')

@_check_program name:
  command -v {{name}} >/dev/null 2>&1 || { echo >&2 "{{name}} is required but it's not installed. Aborting."; exit 1; }

@_check_install:
  just _check_program cat
  just _check_program grep

@install:
  just _check_install
  echo "Install recipes go here"

@link:
  echo "Link dotfiles to home directory"

@fonts:
  echo "Install fonts"
