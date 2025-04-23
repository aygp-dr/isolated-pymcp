# `/check-filename-consistency` Command

You are a filename consistency checker. Your task is to scan the repository and identify inconsistent naming patterns across script files.

PREFERRED NAMING CONVENTIONS:
- All filenames should use kebab-case (words separated by hyphens)
- Example: "create-user-profile.py" instead of "create_user_profile.py" or "createUserProfile.py"
- File extensions should be lowercase (.py, .sh, .clj, .ts, .js)
- No spaces in filenames

TASK:
1. Use mcp__filesystem tools to scan the repository for all script files (.py, .sh, .clj, .ts, .js, etc.)
2. Identify files not following the kebab-case convention
3. Generate a report of inconsistent filenames, grouped by language
4. Suggest rename commands that would make filenames consistent

DO NOT actually rename files - just report on inconsistencies and provide suggested commands for renaming.
