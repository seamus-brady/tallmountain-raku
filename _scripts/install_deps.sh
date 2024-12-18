#!/bin/bash
set -e
# set -x

# ********************************
# install project dependencies
# ********************************
cd "${0%/*}"
cd ..

# Save the current directory
current_dir=$(pwd)
echo "Current directory: $current_dir"

# zef command
ZEF_CMD="zef install --verbose --/test "

echo "Installing project dependencies..."

# install dependencies not in raku.land or that cause issues
temp_dir=$(mktemp -d)
git clone https://github.com/JuneKelly/perl6-config-clever "$temp_dir"
cd "$temp_dir"
$ZEF_CMD .
cd "$current_dir"

temp_dir=$(mktemp -d)
git clone https://github.com/skinkade/crypt-random "$temp_dir"
cd "$temp_dir"
$ZEF_CMD .
cd "$current_dir"

temp_dir=$(mktemp -d)
git clone https://github.com/JJ/Raku-Digest-HMAC.git "$temp_dir"
cd "$temp_dir"
$ZEF_CMD .
cd "$current_dir"

temp_dir=$(mktemp -d)
git clone https://github.com/retupmoca/p6-markdown.git "$temp_dir"
cd "$temp_dir"
$ZEF_CMD .
cd "$current_dir"

# install dependencies
$ZEF_CMD Array::Circular
$ZEF_CMD Docker::File
$ZEF_CMD File::Ignore
$ZEF_CMD IO::Socket::Async::SSL
$ZEF_CMD Digest::SHA1::Native
$ZEF_CMD JSON::Unmarshal
$ZEF_CMD JSON::Fast
$ZEF_CMD OO::Monitors
$ZEF_CMD Shell::Command
$ZEF_CMD DBIish::Pool
$ZEF_CMD JSON::JWT
$ZEF_CMD TinyFloats
$ZEF_CMD CBOR::Simple
$ZEF_CMD Log::Timeline
$ZEF_CMD Text::Markdown
$ZEF_CMD Terminal::ANSIColor
$ZEF_CMD Base64
$ZEF_CMD IO::Socket::SSL
$ZEF_CMD IO::Path::ChildSecure
$ZEF_CMD JSON::JWT
$ZEF_CMD HTTP::HPACK
$ZEF_CMD Cro::Core
$ZEF_CMD Cro::TLS
$ZEF_CMD https://github.com/croservices/cro-http.git
$ZEF_CMD App::Prove6
$ZEF_CMD Env::Dotenv
$ZEF_CMD HTTP::Tinyish
$ZEF_CMD JSON::Fast
$ZEF_CMD Logger
$ZEF_CMD UUID::V4
$ZEF_CMD W3C::DOM
$ZEF_CMD Method::Also
$ZEF_CMD Linenoise

temp_dir=$(mktemp -d)
git clone https://github.com/libxml-raku/LibXML-raku.git "$temp_dir"
cd "$temp_dir"
$ZEF_CMD .
cd "$current_dir"

echo "Done installing project dependencies."