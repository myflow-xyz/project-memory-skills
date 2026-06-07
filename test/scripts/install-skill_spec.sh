Describe "scripts/install-skill.sh"
  project_root=${SHELLSPEC_PROJECT_ROOT:-$(pwd)}
  script=$project_root/scripts/install-skill.sh
  source_skill=$project_root/skills/pmem

  install_codex_user() {
    CODEX_HOME=$SHELLSPEC_WORKDIR/codex HOME=$SHELLSPEC_WORKDIR/home "$script" --agent codex || return
    test -f "$SHELLSPEC_WORKDIR/codex/skills/pmem/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/codex/skills/pmem/references/cli.md" || return
    test -f "$SHELLSPEC_WORKDIR/codex/skills/pmem/.pmem-skills-install"
  }

  install_claude_user() {
    HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude || return
    test -f "$SHELLSPEC_WORKDIR/home/.claude/skills/pmem/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/home/.claude/skills/pmem/.pmem-skills-install"
  }

  install_claude_project() {
    command mkdir -p "$SHELLSPEC_WORKDIR/project" || return
    (
      cd "$SHELLSPEC_WORKDIR/project" || return
      HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude --scope project
    ) || return
    test -f "$SHELLSPEC_WORKDIR/project/.claude/skills/pmem/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/project/.claude/skills/pmem/.pmem-skills-install"
  }

  dry_run_codex() {
    CODEX_HOME=$SHELLSPEC_WORKDIR/dry-run-codex HOME=$SHELLSPEC_WORKDIR/dry-run-home "$script" --agent codex --dry-run || return
    ! test -e "$SHELLSPEC_WORKDIR/dry-run-codex"
  }

  verbose_codex() {
    PMEM_SKILLS_VERBOSE=1 CODEX_HOME=$SHELLSPEC_WORKDIR/verbose-codex HOME=$SHELLSPEC_WORKDIR/verbose-home "$script" --agent codex --dry-run
  }

  missing_agent() {
    HOME=$SHELLSPEC_WORKDIR/home "$script"
  }

  missing_dependency() {
    command mkdir -p "$SHELLSPEC_WORKDIR/bin" || return
    PATH=$SHELLSPEC_WORKDIR/bin CODEX_HOME=$SHELLSPEC_WORKDIR/codex HOME=$SHELLSPEC_WORKDIR/home "$script" --agent codex
  }

  unmanaged_conflict() {
    command mkdir -p "$SHELLSPEC_WORKDIR/conflict-dest" || return
    printf '%s\n' custom > "$SHELLSPEC_WORKDIR/conflict-dest/SKILL.md" || return
    "$script" --agent codex --dest "$SHELLSPEC_WORKDIR/conflict-dest"
  }

  managed_update() {
    dest=$SHELLSPEC_WORKDIR/managed-dest
    "$script" --agent codex --dest "$dest" >/dev/null || return
    printf '%s\n' changed > "$dest/SKILL.md" || return
    "$script" --agent codex --dest "$dest" || return
    command cmp -s "$dest/SKILL.md" "$source_skill/SKILL.md"
  }

  It "installs the PMem skill for Codex user scope"
    When call install_codex_user
    The status should be success
    The output should include "agent=codex"
    The output should include "ok"
  End

  It "installs the PMem skill for Claude Code user scope"
    When call install_claude_user
    The status should be success
    The output should include "agent=claude"
    The output should include "ok"
  End

  It "installs the PMem skill for Claude Code project scope"
    When call install_claude_project
    The status should be success
    The output should include "scope=project"
    The output should include "ok"
  End

  It "supports dry run without writing the destination"
    When call dry_run_codex
    The status should be success
    The output should include "dry-run"
    The output should include "dest="
  End

  It "supports verbose output"
    When call verbose_codex
    The status should be success
    The output should include "source="
    The output should include "scope=user"
  End

  It "fails fast when the required agent argument is missing"
    When call missing_agent
    The status should be failure
    The error should include "missing --agent"
  End

  It "fails fast when a required dependency is missing"
    When call missing_dependency
    The status should be failure
    The error should include "missing required command"
  End

  It "fails safely when the destination is unmanaged"
    When call unmanaged_conflict
    The status should be failure
    The error should include "not managed"
  End

  It "updates a managed destination"
    When call managed_update
    The status should be success
    The output should include "action=update"
    The output should include "ok"
  End
End
