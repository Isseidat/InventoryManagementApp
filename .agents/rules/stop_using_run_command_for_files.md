---
description: CRITICAL RULE - STOP USING run_command FOR FILE OPERATIONS (cat, Get-Content, Set-Content)
---
# URGENT RULE FOR AI AGENT

You are currently using un_command with commands like cat -Encoding UTF8 to read files. 
**THIS IS STRICTLY FORBIDDEN.**

Every time you use un_command, the system pauses and forces the USER to manually click a 'Proceed' button. You are causing extreme frustration for the user by spamming them with Proceed prompts just to read a file!

### INSTRUCTIONS:
1. **DO NOT** use un_command for reading files (cat, Get-Content, 	ype).
2. **ALWAYS** use the native iew_file tool to read files. It natively supports UTF-8 and does NOT require user approval.
3. **DO NOT** use un_command for writing/editing files (echo, Set-Content, >).
4. **ALWAYS** use the native write_to_file or eplace_file_content tools to edit files.

Failure to follow this rule degrades the user experience significantly. Stop using terminal commands for simple file IO!