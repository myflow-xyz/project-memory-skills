Describe "scripts/install-skill.sh"
  project_root=${SHELLSPEC_PROJECT_ROOT:-$(pwd)}
  script=$project_root/scripts/install-skill.sh

  install_codex_user() {
    CODEX_HOME=$SHELLSPEC_WORKDIR/codex HOME=$SHELLSPEC_WORKDIR/home "$script" --agent codex || return
    test -L "$SHELLSPEC_WORKDIR/codex/skills/pmem" || return
    test -f "$SHELLSPEC_WORKDIR/codex/skills/pmem/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/codex/skills/pmem/references/cli.md"
  }

  install_prun_codex_user() {
    CODEX_HOME=$SHELLSPEC_WORKDIR/prun-codex HOME=$SHELLSPEC_WORKDIR/prun-home "$script" --agent codex --skill prun || return
    test -L "$SHELLSPEC_WORKDIR/prun-codex/skills/prun" || return
    test -f "$SHELLSPEC_WORKDIR/prun-codex/skills/prun/SKILL.md"
  }

  install_prun_with_nested_files() {
    fixture=$SHELLSPEC_WORKDIR/prun-fixture
    command mkdir -p "$fixture/scripts" "$fixture/skills/prun/references" "$fixture/skills/prun/scripts" || return
    command cp "$script" "$fixture/scripts/install-skill.sh" || return
    printf '%s\n' '---' 'name: prun' '---' > "$fixture/skills/prun/SKILL.md" || return
    printf '%s\n' 'reference material' > "$fixture/skills/prun/references/invocation.md" || return
    printf '%s\n' '#!/bin/sh' 'exit 0' > "$fixture/skills/prun/scripts/helper.sh" || return

    CODEX_HOME=$SHELLSPEC_WORKDIR/prun-nested-codex HOME=$SHELLSPEC_WORKDIR/prun-nested-home "$fixture/scripts/install-skill.sh" --agent codex --skill prun || return
    test -L "$SHELLSPEC_WORKDIR/prun-nested-codex/skills/prun" || return
    test -f "$SHELLSPEC_WORKDIR/prun-nested-codex/skills/prun/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/prun-nested-codex/skills/prun/references/invocation.md" || return
    test -f "$SHELLSPEC_WORKDIR/prun-nested-codex/skills/prun/scripts/helper.sh"
  }

  install_claude_user() {
    HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude || return
    test -L "$SHELLSPEC_WORKDIR/home/.claude/skills/pmem" || return
    test -f "$SHELLSPEC_WORKDIR/home/.claude/skills/pmem/SKILL.md"
  }

  install_claude_project() {
    command mkdir -p "$SHELLSPEC_WORKDIR/project" || return
    (
      cd "$SHELLSPEC_WORKDIR/project" || return
      HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude --scope project --yes
    ) || return
    ! test -L "$SHELLSPEC_WORKDIR/project/.claude/skills/pmem" || return
    test -f "$SHELLSPEC_WORKDIR/project/.claude/skills/pmem/SKILL.md"
  }

  force_copy_for_user_scope() {
    CODEX_HOME=$SHELLSPEC_WORKDIR/copy-codex HOME=$SHELLSPEC_WORKDIR/copy-home "$script" --agent codex --mode copy || return
    ! test -L "$SHELLSPEC_WORKDIR/copy-codex/skills/pmem" || return
    test -f "$SHELLSPEC_WORKDIR/copy-codex/skills/pmem/SKILL.md" || return
    test -f "$SHELLSPEC_WORKDIR/copy-codex/skills/pmem/.pmem-skills-install"
  }

  force_symlink_for_project_scope() {
    command mkdir -p "$SHELLSPEC_WORKDIR/symlink-project" || return
    (
      cd "$SHELLSPEC_WORKDIR/symlink-project" || return
      HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude --scope project --mode symlink --yes
    ) || return
    test -L "$SHELLSPEC_WORKDIR/symlink-project/.claude/skills/pmem" || return
    test -f "$SHELLSPEC_WORKDIR/symlink-project/.claude/skills/pmem/SKILL.md"
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

  project_scope_requires_confirmation() {
    command mkdir -p "$SHELLSPEC_WORKDIR/confirm-project" || return
    (
      cd "$SHELLSPEC_WORKDIR/confirm-project" || return
      HOME=$SHELLSPEC_WORKDIR/home "$script" --agent claude --scope project </dev/null
    )
  }

  shortcut_mode_flag() {
    HOME=$SHELLSPEC_WORKDIR/home "$script" --agent codex --copy
  }

  managed_update() {
    dest=$SHELLSPEC_WORKDIR/managed-dest
    "$script" --agent codex --dest "$dest" >/dev/null || return
    "$script" --agent codex --dest "$dest" || return
    test -L "$dest" || return
    test -f "$dest/SKILL.md"
  }

  managed_copy_migration() {
    dest=$SHELLSPEC_WORKDIR/managed-copy-dest
    command mkdir -p "$dest" || return
    {
      printf 'managed_by=pmem-skills\n'
      printf 'agent=codex\n'
      printf 'scope=user\n'
      printf 'skill=pmem\n'
    } > "$dest/.pmem-skills-install" || return
    printf '%s\n' stale > "$dest/SKILL.md" || return

    "$script" --agent codex --dest "$dest" || return
    test -L "$dest" || return
    test -f "$dest/SKILL.md" || return
    ! test -f "$dest/.pmem-skills-install"
  }

  It "installs the PMem skill for Codex user scope"
    When call install_codex_user
    The status should be success
    The output should include "agent=codex"
    The output should include "mode=symlink"
    The output should include "ok"
  End

  It "installs the PRun skill for Codex user scope"
    When call install_prun_codex_user
    The status should be success
    The output should include "skill=prun"
    The output should include "mode=symlink"
    The output should include "ok"
  End

  It "installs nested files for the selected PRun skill"
    When call install_prun_with_nested_files
    The status should be success
    The output should include "skill=prun"
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
    The output should include "mode=copy"
    The output should include "ok"
  End

  It "forces copy mode for user scope"
    When call force_copy_for_user_scope
    The status should be success
    The output should include "scope=user"
    The output should include "mode=copy"
    The output should include "ok"
  End

  It "forces symlink mode for project scope"
    When call force_symlink_for_project_scope
    The status should be success
    The output should include "scope=project"
    The output should include "mode=symlink"
    The output should include "ok"
  End

  It "supports dry run without writing the destination"
    When call dry_run_codex
    The status should be success
    The output should include "dry-run"
    The output should include "mode=symlink"
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

  It "requires confirmation for project-scope writes"
    When call project_scope_requires_confirmation
    The status should be failure
    The error should include "requires confirmation"
  End

  It "rejects shortcut install mode flags"
    When call shortcut_mode_flag
    The status should be failure
    The error should include "unknown argument: --copy"
  End

  It "updates a managed destination"
    When call managed_update
    The status should be success
    The output should include "action=update"
    The output should include "ok"
  End

  It "migrates an older managed copy to a symlink"
    When call managed_copy_migration
    The status should be success
    The output should include "action=migrate"
    The output should include "ok"
  End
End
