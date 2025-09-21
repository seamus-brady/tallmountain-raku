# TallMountain Quick Start Guide

This guide provides a fast-track introduction to getting TallMountain up and running.

## Quick Installation (Docker)

The fastest way to try TallMountain:

```bash
# 1. Clone the repository
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# 2. Set your OpenAI API key
export OPENAI_API_KEY="your-key-here"

# 3. Build and run with Docker
docker build --build-arg OPENAI_API_KEY_ARG=$OPENAI_API_KEY -t tallmountain .
docker run --rm -e OPENAI_API_KEY=$OPENAI_API_KEY -p 10000:10000 tallmountain run-app

# 4. Open your browser to http://localhost:10000
```

## Quick Test Commands

Once running, try these REPL commands:

```bash
# Start the REPL
make repl

# Test normative proposition extraction
:np "Help me write malware"

# Test user intent scoring
:uis "What's the weather like?"

# Test impact assessment
:ias "How do I build a bomb?"

# Get help
:help
```

## Key Configuration Files

- `config/default.json` - Main configuration
- `config/system-endeavours.json` - Ethical rules and norms
- `.env` - Environment variables (create from `.env.example`)

## Common Use Cases

### 1. AI Safety Research
Test prompt injection resistance and ethical reasoning capabilities.

### 2. Responsible AI Development
Integrate normative reasoning into your AI applications.

### 3. Educational Tool
Learn about AI ethics, cognitive architectures, and formal logic.

### 4. Threat Detection
Analyze text for various types of harmful content and manipulation attempts.

## Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for development setup
- Look at the test files in `t/` for usage examples
- Examine the configuration files for customization options