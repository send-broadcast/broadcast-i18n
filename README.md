# Broadcast translations

Translations of the [Broadcast](https://sendbroadcast.net) admin interface: the
pages people use to run their newsletters, subscribers, sequences and sending.

| Language | File |
|---|---|
| Italian | `locales/admin.it.yml` |
| French | `locales/admin.fr.yml` |
| German | `locales/admin.de.yml` |

English is written in the Broadcast application itself. `reference/admin.en.yml`
is a copy of it, kept here so you can see what every key says. Pages subscribers
see (unsubscribe, confirmation and opt-in pages) are not in this repository.

## Suggesting a change

Spotted a translation that reads wrong, or a term used inconsistently? Open a pull
request against the file for your language, or an issue if you would rather
describe it. See [CONTRIBUTING.md](CONTRIBUTING.md).

Each language file starts with its style notes and glossary. Following them keeps
one thing called by one name across the whole interface.

## Checking your change

```sh
bundle install
bin/check          # every language
bin/check fr       # one language
bin/check fr --missing   # also list keys not translated yet
```

`bin/check` fails on anything that would break the interface: a key English does
not have, a `%{placeholder}` that was renamed or dropped, HTML that changed in a
key ending in `_html`, a broken plural, an empty value or a long dash. A key that
is not translated yet is not an error, because Broadcast shows the English until it
is. It only lowers the coverage figure.

## How translations reach Broadcast

Broadcast loads this repository as a gem. Merged changes ship with the next
Broadcast release.

## Adding a language

Open an issue first. A new language needs a complete first pass and someone willing
to review changes to it.

## License

MIT. See [LICENSE](LICENSE).
