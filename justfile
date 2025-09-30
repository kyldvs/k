set fallback := true
set shell := ["bash", "-uc"]
set ignore-comments

@_default:
  just --list

@help:
  just --list

mod hooks "tasks/hooks"
mod test "tasks/test"
mod vcs "tasks/vcs"

home_dir := env_var('HOME')

