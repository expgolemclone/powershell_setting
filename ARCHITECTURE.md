# Architecture

PowerShell プロファイルおよびカスタムモジュールのリポジトリ。

## ファイル構成

```
.
├── Microsoft.PowerShell_profile.ps1  # PowerShell プロファイル（エイリアス・プロンプト設定）
├── Modules/
│   └── PSTodoist/                    # Todoist 連携モジュール
│       ├── PSTodoist.psd1            # モジュールマニフェスト
│       ├── PSTodoist.psm1            # モジュール本体
│       └── config.json               # 設定ファイル
├── scripts/
│   └── open-terminal-here.exe        # エクスプローラーからターミナルを開くユーティリティ
├── CLAUDE.md                         # Claude Code プロジェクト設定
└── .gitignore
```

## エイリアス一覧

| エイリアス | コマンド |
|-----------|---------|
| `l` | `Clear-Host` + `Get-ChildItem` |
| `la` | `Get-ChildItem -Force` |
| `c` | `Clear-Host` |
| `n` | `nvim` |
| `cl` | `claude --effort max` |
| `co` | `codex` |
| `t` | `Clear-Host` + `todoist` |
| `u` | `uv run python` |
| `g` | `glow --style dark` |
| `tree` | カスタム Tree 実装 |
| `sudo` | `gsudo` |
