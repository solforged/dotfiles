# Copies the XDG and tool-home variables from .zshenv into the launchd user
# session, so GUI apps and LaunchAgents started afterwards write to the same
# places as the shell. The dev.mise.session-env agent runs this at login; zsh
# has already read ~/.zshenv by the time it gets here.
names=(
  XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  DOCKER_CONFIG GNUPGHOME
  CARGO_HOME RUSTUP_HOME GOPATH GOBIN BUN_INSTALL npm_config_cache
  GRADLE_USER_HOME PUB_CACHE GEM_SPEC_CACHE MPLCONFIGDIR CODEX_HOME
)
for name in $names; do
  if [[ -n "${(P)name}" ]]; then
    /bin/launchctl setenv "$name" "${(P)name}"
  else
    /bin/launchctl unsetenv "$name"
  fi
done
