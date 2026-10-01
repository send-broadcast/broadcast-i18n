# Contributing

Thank you for helping Broadcast read well in your language.

## What to change

- Translations live in `locales/admin.<language>.yml`. Change only these files.
- `reference/admin.en.yml` is generated from Broadcast. Do not edit it. If the
  English itself is wrong or unclear, open an issue.
- Keep the key structure exactly as it is. Translate values, never keys.

## Rules every translation follows

1. Keep `%{placeholders}` exactly as written. They are filled in by Broadcast
   (`%{name}`, `%{count}`...). You may move them within the sentence.
2. Keys ending in `_html` contain HTML. Keep the tags and attributes; translate the text.
3. Plurals have a `one` and an `other` form.
4. No long dashes (em dash or en dash). Use a comma, a colon, parentheses or a new sentence.
5. Do not translate product and brand names (Broadcast, Postmark, Amazon SES,
   SendGrid...), DNS and protocol names (SPF, DKIM, DMARC, API, SMTP), or code
   such as `{{ first_name }}`.
6. Follow the style notes and glossary at the top of your language's file. If you
   think a glossary term is wrong, propose the change in an issue so it can be
   changed everywhere at once.

## Before you open a pull request

Run `bin/check` and make sure it reports no errors for your language.

Describe what you changed and why, especially for wording changes that are a
matter of preference rather than a mistake. A native speaker reviews every
pull request.

## Licence of contributions

By opening a pull request you agree that your contribution is licensed under the
MIT licence of this repository, and that it may ship in Broadcast.
