# 🗂️ Windows Folder Organizer

A lightweight Windows GUI tool that automatically sorts files in any folder into categorized subfolders — no installation required, just double-click and go.

![Folder Organizer Screenshot](screenshot.png)

---

## ✨ Features

- 📁 **Browse or type** any folder path
- 🖱️ **One-click** organization
- 📊 **Live activity log** showing every file moved
- 📈 **Progress bar** while organizing
- 🔁 **Duplicate handling** — appends `_1`, `_2`, etc. automatically
- ⚡ **No installation needed** — runs on any Windows PC with PowerShell

---

## 📂 File Categories

| Folder | File Types |
|--------|-----------|
| 📄 Documents/PDFs | `.pdf` |
| 📝 Documents/Word | `.doc`, `.docx` |
| 📊 Documents/Excel | `.xls`, `.xlsx`, `.csv` |
| 📑 Documents/PowerPoint | `.ppt`, `.pptx` |
| 📃 Documents/Text | `.txt`, `.rtf`, `.md` |
| 🖼️ Images | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.webp`, `.svg`, `.heic`, `.raw` |
| 🎬 Videos | `.mp4`, `.mov`, `.avi`, `.mkv`, `.wmv`, `.flv`, `.m4v`, `.webm` |
| 🎵 Music | `.mp3`, `.wav`, `.flac`, `.aac`, `.ogg`, `.wma`, `.m4a` |
| ⚙️ Installers | `.exe`, `.msi`, `.msix`, `.appx`, `.dmg`, `.pkg`, `.deb`, `.rpm` |
| 📦 Compressed | `.zip`, `.rar`, `.7z`, `.tar`, `.gz`, `.bz2`, `.xz` |
| 💻 Code | `.py`, `.js`, `.ts`, `.html`, `.css`, `.json`, `.xml`, `.sql`, `.sh`, `.bat`, `.ps1` |
| 🔤 Fonts | `.ttf`, `.otf`, `.woff`, `.woff2` |
| 🌀 Torrents | `.torrent` |
| 📁 Other | Everything else |

---

## 🚀 How to Use

1. **Download** `FolderOrganizer.bat`
2. **Double-click** it — a GUI window will open
3. **Type or browse** to any folder you want to organize
4. Click **"Organize Folder"**
5. Watch the activity log as files get sorted!

---

## 💻 Requirements

- Windows 10 or 11
- PowerShell (pre-installed on all modern Windows systems)

No Python, no Node.js, no dependencies — just Windows.

---

## ⚠️ Notes

- Files are **moved**, not copied — originals will no longer be in the root folder
- The tool **skips itself** so it won't accidentally move its own file
- Subfolders inside the target folder are **not touched** — only root-level files are organized

---

## 🛠️ How It Works

`FolderOrganizer.bat` is a self-contained batch file that extracts an embedded PowerShell GUI script at runtime, runs it, then cleans up the temp file automatically. Nothing is left behind on your system.

---

## 📄 License

MIT License — free to use, modify, and distribute.
