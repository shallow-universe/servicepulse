# ServicePulse

**ServicePulse** is a lightweight Linux service monitoring and recovery utility built with Bash. It helps system administrators and DevOps engineers quickly check service health, uptime, availability, and perform automated recovery actions using `systemd`.

Designed for production environments, internal operations teams, and Linux server management.

---

# 📌 Features

- Monitor a single Linux service
- Monitor all registered services
- View service uptime
- Detect stopped / failed services
- Add or remove services from watchlist
- Auto-heal down services using restart action
- Summary report of running/down services
- Colored CLI output for readability
- Event logging for operational tracking

---

# 🛠️ Tech Stack

* Bash Scripting
* Linux
* systemd / systemctl
* CLI Automation

---

# 📂 Project Structure

```text
servicepulse/
├── servicepulse.sh
├── README.md
└── /opt/servicepulse/
    ├── services.list
    └── servicepulse.log
```

---

# ⚙️ Installation

## 1. Clone Repository

```bash
git clone https://github.com/shallow-universe/servicepulse.git
cd servicepulse
```

## 2. Make Executable

```bash
chmod +x servicepulse.sh
```

## 3. Move to System Path (Optional)

```bash
mv servicepulse.sh /usr/bin/servicepulse
chmod +x /usr/bin/servicepulse
```

Now run:

```bash
servicepulse
```

---

# 🚀 Usage

## Check All Registered Services

```bash
servicepulse all
```

## Check Single Service

```bash
servicepulse sshd
```

## Add Service to Monitoring List

```bash
servicepulse add nginx
```

## Remove Service

```bash
servicepulse del nginx
```

## Auto-Heal Failed Service

```bash
servicepulse heal nginx
```

## Summary Report

```bash
servicepulse summary
```

---

# 📸 Example Output

```text
SERVICE                   STATUS          UPTIME
----------------------------------------------------
sshd                      RUNNING         15m
nginx                     DOWN            -
mysql                     RUNNING         2h
```

---

# 🧠 How It Works

ServicePulse uses `systemctl` to:

* Check service state
* Detect active/inactive services
* Calculate uptime
* Restart failed services
* Maintain monitoring list
* Generate logs

---

# 📝 Logs

All events are stored in:

```bash
/opt/servicepulse/servicepulse.log
```

Example:

```text
2026-04-22 10:30:11 | nginx restarted successfully
2026-04-22 10:45:07 | mysql added to monitoring list
```

---

# 🎯 Use Cases

* Linux Server Administration
* DevOps Operations
* Internal Infrastructure Monitoring
* Service Health Checks
* Self-Healing Utilities
* Lab / Homelab Monitoring

---

# 🔥 Future Enhancements

* Email / Slack / Teams Alerts
* Cron Scheduler
* HTML Dashboard
* Multi-Server SSH Monitoring
* Docker / Kubernetes Support
* JSON Export Reports

---

# 🤝 Contributing

Pull requests and improvements are welcome.

---

# 📄 License

MIT License

---

# ⭐ If you found this useful, give the repo a star!
