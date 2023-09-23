# Shell Stuff

Dotfiles and system setup for Dagan

## Usage

`./bootstrap.sh --profile <profile>`

## Profiles

Profiles can enable and disable features, specify specific packages, and run
arbitrary commands. Profiles inherit from other profiles. Each profile should
have at most one parent.

Profies are listed `./profiles`

## Testing with docker

`docker build -f docker/<dockerfile> .`
