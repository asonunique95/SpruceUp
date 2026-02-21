# Product Guidelines - Evergreen Library Automation

## Documentation & Logs
- **Style:** **Technical & Concise**. All documentation, commit messages, and logs must prioritize clarity and brevity. Avoid fluff and focus on providing factual, high-signal information.
- **Language:** Use precise technical terminology (e.g., "idempotent," "manifest," "singleton").

## User Experience (UX)
The user experience, whether through CLI output or log files, must adhere to these core principles:
- **Efficiency-First:** Prioritize automation and sensible defaults. The tool should require minimal user interaction for standard operations.
- **Informative Feedback:** Provide clear, real-time status updates for every significant action (e.g., "Downloading Google Chrome...", "Successfully created PSADT package...").
- **Safe & Reversible:** Ensure all file system operations (downloads, moves, deletions) are performed safely. Use temporary directories where appropriate and implement retry logic for transient network failures.

## Branding & Visual Style
- **Identity:** **Native PowerShell**. The tool must look and feel like a standard PowerShell module/script. Follow standard PowerShell naming conventions (e.g., Verb-Noun) and use default console formatting (e.g., `Write-Verbose`, `Write-Error`) to ensure seamless integration with the user's existing environment.
- **Console Output:** Use standard PowerShell color schemes for different message types (e.g., Green for success, Yellow for warnings, Red for errors).
