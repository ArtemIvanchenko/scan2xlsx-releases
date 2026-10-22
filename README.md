# Scan2XLSX releases

Установщик и сборки Scan2XLSX для macOS на Apple Silicon. Исходники и тестовые
документы здесь не публикуются.

## Установка

```bash
curl -fsSL https://raw.githubusercontent.com/ArtemIvanchenko/scan2xlsx-releases/main/install.sh | bash
```

Установщик скачает последний релиз, проверит SHA256, установит приложение в
`~/Applications/Scan2XLSX.app`, снимет карантин macOS и запустит его.

Аккаунт Apple Developer и нотаризация не требуются: приложение подписано ad-hoc.
Именно поэтому его нужно запускать через установщик, а не двойным щелчком по
скачанному ZIP.

Обновление — той же командой. Удаление:

```bash
rm -rf ~/Applications/Scan2XLSX.app
```

## Движки

- Apple Vision — по умолчанию, системный OCR macOS.
- RapidOCR (PP-OCRv5 eslav) — офлайн, не использует Apple Vision; выбирается в
  интерфейсе.

## Требования

- macOS 13+.
- Apple Silicon (M1/M2/M3/M4).
- Около 400 МБ свободного места.
