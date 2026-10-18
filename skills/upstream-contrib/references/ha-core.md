# Home Assistant core changes

Moved out of SKILL.md on 2026-10-18 so only the repo being worked on loads.

### HA core changes (WSL test env, learned 2026-08-29)

- HA tests cannot run on Windows (`fcntl` import in the runner). WSL env: uv-managed Python (match `pyproject` floor, was 3.14.2), `uv pip install -e . -r requirements_test.txt` + the integration's manifest deps; extract extra per-domain deps from `requirements_all.txt` by its `# homeassistant.components.X` comments instead of whack-a-mole.
- **Run `python -m script.translations develop --all` before any test that loads service descriptions** - without it teardown fails "Translation not found" on core services and a whole file looks broken (143 phantom errors vs 143 passed after).
- **A locally-built aioesphomeapi in the HA venv gets silently clobbered** by any later install whose deps pin it (bleak-esphome). Reinstall and verify the import (`UserServiceArg(optional=...)`) immediately before trusting a test run or a live demo; AttributeError in `_async_register_service` at runtime = stale copy.
- **WSL VM lifecycle bites twice:** when the last Windows-side handle exits, the VM idle-stops - killing nohup'd processes (dev hass died repeatedly) AND discarding unsynced disk writes (a venv install evaporated after its own success message). Long-lived processes: run attached under a session background task. After installs: `sync`. /tmp does not survive VM restarts.
- **wsl.exe mangles argument paths** (MSYS rewrites /home, /tmp, even /mnt/c to C:/Program Files/Git/...). Pipe scripts via stdin: `printf '...' | wsl.exe -d Ubuntu -- bash`. Never pass POSIX paths as wsl.exe arguments from Git Bash.
- Dev-HA-for-demo recipe: minimal config (homeassistant/frontend/config keys), add the ESPHome integration by IP, localhost:<port> reachable from Windows via WSL relay - but a Windows process squatting the port silently wins on one address family (stale session servers on 8123 did this); `Get-NetTCPConnection -LocalPort` first.
