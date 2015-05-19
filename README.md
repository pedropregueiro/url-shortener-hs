# URL Shortener (Haskell)

This is a **really** simple URL Shortener shared just to prove the point that Haskell is a great (and modern) language! :P

It was live coded during the Haskell Meetup in Oslo.

## Requirements

* GHC
* Cabal
* SQLite

## Install

After cloning the repository into your computer, you'll have to

1. create a cabal sandbox: `cabal sandbox init`
2. install dependencies: `cabal install --only-dependencies`
2. create a SQLite db called 'mapping':
```
sqlite3 mapping.db 'CREATE TABLE mapping (key text PRIMARY KEY, url text);'
```

## Getting Started

To run the app you just need to do `cabal run` and go to *localhost:3000* and that's it!
