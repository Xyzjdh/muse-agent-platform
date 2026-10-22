# Muse Agent Platform

Agent platform with 54+ skills and 63+ connectors for AI-powered task automation.

## Contents

- `skills/` — 54 task-specific skill modules (documents, goals, health, flight-booking, etc.)
- `assets/` — Runtime assets including voice selector (50+ voices), booking data, and templates
- `assets/spaces/` — TypeScript web artifact runtime (libsql, Playwright, Bun)

## Connectors (symlinks to /opt/hatch/connectors/)

Gmail, Notion, Slack, Spotify, GitHub, Linear, Stripe, Zoom, WhatsApp, Instagram, Twitter/X,
Google Workspace, Outlook, Dropbox, Box, Evernote, Figma, Shopify, Plaid, and 50+ more.

## Skills (selected)

| Category | Skills |
|----------|--------|
| Productivity | documents, goals, task-management, knowledge-organization |
| Communication | email-management, muse-mail, whatsapp, slack, messenger |
| Travel | flight-booking, hotel-booking, trip-planning, navigation |
| Finance | financial-planning, quickbooks, stripe, polymarket |
| Health | health-review, fitness-tracking, nutrition, wearable-comms |
| Commerce | shopping, price-tracker, groceries, printify |
| Media | generate_podcast, spoken-audio, image-search, media-library |
| Social | social-content-performance, social-competitor-analysis, advertising-campaigns |
| Dev | app-creation, custom-connector-setup, skill-creator |

## Installation

1. Extract to `/opt/muse/` (requires root):
   ```bash
   sudo tar xzf muse-package.tar.gz -C /
   ```

2. Ensure hatch daemon is running:
   ```bash
   /opt/hatch/bin/hatch daemon start
   ```

3. Verify:
   ```bash
   /opt/hatch/bin/hatch agents list
   ```

## Requirements

- Linux (x64)
- `hatch` daemon at `/opt/hatch/bin/hatch`
- Root access for `/opt/muse/`
