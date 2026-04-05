#!/bin/bash
# PII Safety Review - Blocks commits/pushes containing personal information
# Protects Cozy Coder from accidentally publishing private info

# Parent override: set COZY_PARENT env var to bypass
if [ "$COZY_PARENT" = "RikusApproved2026" ]; then
  exit 0
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit and git push commands
if ! echo "$COMMAND" | grep -qE 'git (commit|push)'; then
  exit 0
fi

# Get staged diff for commits, or diff of what will be pushed
# Exclude hook scripts themselves (they contain regex patterns with digit sequences)
DIFF_CONTENT=$(git diff --cached -- ':!.claude/hooks/*' ':!.git/hooks/*' 2>/dev/null || true)

# If no staged diff (might be a push), check the last commit
if [ -z "$DIFF_CONTENT" ]; then
  DIFF_CONTENT=$(git diff HEAD~1..HEAD -- ':!.claude/hooks/*' ':!.git/hooks/*' 2>/dev/null || true)
fi

# If still nothing, allow through
if [ -z "$DIFF_CONTENT" ]; then
  exit 0
fi

FOUND_ISSUES=""

# Phone numbers - US formats: (555) 123-4567, 555-123-4567, 5551234567, +1-555-123-4567
if echo "$DIFF_CONTENT" | grep -qE '\(?\b[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b'; then
  # Exclude obvious non-phone patterns (CSS colors, dates, zip codes in code)
  PHONE_MATCHES=$(echo "$DIFF_CONTENT" | grep -E '\(?\b[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b' | grep -vE '(#[0-9a-fA-F]{6}|rgba?\(|185\.199\.|192\.0\.2\.|127\.0\.0\.|0\.0\.0\.|localhost|\.153|port|width|height|size|margin|padding|z-index)' || true)
  if [ -n "$PHONE_MATCHES" ]; then
    FOUND_ISSUES="${FOUND_ISSUES}PHONE NUMBER detected\n"
  fi
fi

# Street addresses - number + street name patterns
if echo "$DIFF_CONTENT" | grep -iqE '\b[0-9]{1,5}\s+(north|south|east|west|n\.?|s\.?|e\.?|w\.?)?\s*(main|oak|elm|maple|cedar|pine|first|second|third|fourth|fifth|broadway|park|washington|lincoln|martin luther king|mlk)\s+(st|street|ave|avenue|blvd|boulevard|dr|drive|ln|lane|rd|road|ct|court|way|pl|place|cir|circle)\b'; then
  FOUND_ISSUES="${FOUND_ISSUES}STREET ADDRESS detected\n"
fi

# More general address pattern - number + word + st/ave/blvd/dr/rd/ln
if echo "$DIFF_CONTENT" | grep -iqE '\b[0-9]{1,5}\s+[a-zA-Z]+\s+(street|avenue|boulevard|drive|lane|road|court|way|place|circle)\b'; then
  FOUND_ISSUES="${FOUND_ISSUES}POSSIBLE ADDRESS detected\n"
fi

# Social Security Numbers
if echo "$DIFF_CONTENT" | grep -qE '\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b'; then
  FOUND_ISSUES="${FOUND_ISSUES}SOCIAL SECURITY NUMBER detected\n"
fi

# Email addresses (but allow @example.com, @gmail.com in code examples)
if echo "$DIFF_CONTENT" | grep -qE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'; then
  REAL_EMAILS=$(echo "$DIFF_CONTENT" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | grep -ivE '(example\.com|test\.com|noreply@|placeholder|fake|@anthropic\.com)' || true)
  if [ -n "$REAL_EMAILS" ]; then
    FOUND_ISSUES="${FOUND_ISSUES}EMAIL ADDRESS detected: may be personal\n"
  fi
fi

# Full names near identifying context (e.g., "my name is", "I'm [Name]", "Cozy Coder [LastName]")
if echo "$DIFF_CONTENT" | grep -iqE '(my name is|i am|i'\''m)\s+[A-Z][a-z]+\s+[A-Z][a-z]+'; then
  FOUND_ISSUES="${FOUND_ISSUES}POSSIBLE FULL NAME with context detected\n"
fi

# School names
if echo "$DIFF_CONTENT" | grep -iqE '\b(school|elementary|middle school|high school|academy|preparatory|montessori)\b.*\b(name|attend|go to|student)\b|\b(attend|go to|student at)\b.*\b(school|elementary|academy)\b'; then
  FOUND_ISSUES="${FOUND_ISSUES}SCHOOL REFERENCE detected\n"
fi

# API keys and secrets (general protection)
if echo "$DIFF_CONTENT" | grep -qiE '(api[_-]?key|secret[_-]?key|access[_-]?token|private[_-]?key)\s*[:=]\s*['\''"]?[a-zA-Z0-9]'; then
  FOUND_ISSUES="${FOUND_ISSUES}API KEY or SECRET detected\n"
fi

# If issues found, block the command
if [ -n "$FOUND_ISSUES" ]; then
  REASON=$(printf "SAFETY BLOCK: Personal information detected in code!\n\n%b\nPlease remove any personal information before committing. Ask a parent if you are not sure." "$FOUND_ISSUES")
  jq -n \
    --arg reason "$REASON" \
    '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
  exit 0
fi

# All clear
exit 0
