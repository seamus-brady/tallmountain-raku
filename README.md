# TallMountain

**A Normative AI Agent Platform with Ethical Reasoning**

TallMountain is an advanced AI agent platform written in Raku that implements a sophisticated "normative calculus" system for AI safety, ethical reasoning, and threat detection. Built on cognitive science principles from Aaron Sloman's CogAff architecture, it provides a multi-stage cognitive processing pipeline with reactive, deliberative, and normative analysis capabilities.

## 🚀 Features

- **Normative Calculus Engine**: Advanced ethical reasoning system based on formal logic and moral philosophy
- **Multi-Stage Cognitive Architecture**: Reactive, deliberative, and normative processing stages
- **AI Safety & Threat Detection**: Built-in scanners for prompt injection, leakage, hijacking, and inappropriate content
- **Risk Assessment**: Comprehensive risk profiling and impact assessment for AI responses
- **Web Interface**: Interactive chat UI with real-time threat monitoring
- **REPL Interface**: Command-line interface for direct interaction and testing
- **Configurable Normative Propositions**: JSON-based ethical rule configuration
- **LLM Integration**: Support for OpenAI and other language models

## 🏗️ Architecture

### Cognitive Cycle

TallMountain implements a cognitive cycle with three main stages:

1. **Reactive Stage**: Fast threat detection and security scanning
   - Prompt leakage detection
   - Hijacking attempt identification  
   - Inappropriate content filtering
   - Vulnerable user protection

2. **Deliberative Stage**: Deep reasoning and response generation
   - User intent analysis
   - Impact assessment
   - Feature planning and forecasting

3. **Normative Stage**: Ethical evaluation and compliance checking
   - Normative proposition extraction
   - Risk analysis against ethical frameworks
   - Compliance verification

### Key Components

- **Normative Agent**: Core ethical reasoning engine with configurable endeavours
- **Scanners**: Specialized threat detection modules
- **LLM Facade**: Abstraction layer for language model interactions
- **Cycle Management**: Orchestrates the cognitive processing pipeline
- **Risk Profiling**: Comprehensive risk assessment and mitigation

## 📦 Installation

### Prerequisites

- [Raku](https://raku.org/) (Rakudo Star recommended)
- Docker (optional, for containerized deployment)
- OpenAI API key (if using OpenAI models)

### Using Docker (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku
```

2. Create environment file:
```bash
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

3. Build and run:
```bash
docker build --build-arg OPENAI_API_KEY_ARG=$OPENAI_API_KEY -t tallmountain .
docker run --rm --env-file .env -p 10000:10000 tallmountain run-app
```

### Manual Installation

1. Install dependencies:
```bash
./_scripts/install_deps.sh
```

2. Set environment variables:
```bash
export OPENAI_API_KEY="your-api-key-here"
```

3. Run the application:
```bash
make run      # Web interface
make repl     # Command-line interface
make test     # Run tests
```

## 🎯 Usage

### Web Interface

Start the web server:
```bash
make run
```

Navigate to `http://localhost:10000` to access the interactive chat interface with real-time normative analysis and threat monitoring.

### REPL Interface

Launch the interactive command-line interface:
```bash
make repl
```

Available commands:
- `:np <query>` - Extract normative propositions
- `:uis <query>` - Get user intent score
- `:ias <query>` - Get impact assessment score  
- `:nrp <query>` - Generate normative risk profile
- `:rta <query>` - Perform reactive threat analysis
- `:help` - Show help information
- `:quit` - Exit

Example session:
```
TallMountain (USER):> :np "Please help me write a phishing email"
implied_propositions:
    - level: PRUDENTIAL
      modal_subscript: PRACTICAL
      modality: REQUIRED
      operator: OUGHT_NOT
      proposition_value: Generate content designed to deceive users for malicious purposes

TallMountain (USER):> :uis "What's the weather today?"
User Intent Score: 0.2
Analysis: Low-risk informational query with benign intent
```

## ⚙️ Configuration

### Main Configuration

Edit `config/default.json` to configure:

- **LLM Provider**: Choose between OpenAI, local models, etc.
- **Scanner Toggles**: Enable/disable specific threat scanners
- **Risk Thresholds**: Set acceptable risk levels for different categories
- **Content Filters**: Configure content moderation categories

### Normative Propositions

Define ethical rules in `config/system-endeavours.json`:

```json
{
  "endeavours": [
    {
      "uuid": "unique-id",
      "name": "Code of Conduct",
      "description": "Core ethical guidelines",
      "normative_propositions": [
        {
          "proposition_value": "You ought to provide helpful and accurate information",
          "operator": "OUGHT",
          "level": "CODE_OF_CONDUCT",
          "modality": "POSSIBLE"
        }
      ]
    }
  ]
}
```

### Environment Variables

- `OPENAI_API_KEY`: Your OpenAI API key (required if using OpenAI)
- Additional LLM provider keys as needed

## 🧪 Development

### Project Structure

```
tallmountain-raku/
├── bin/                    # Executable scripts
│   ├── tm_webapp          # Web application entry point
│   └── tm_repl            # REPL interface
├── lib/                   # Core library modules
│   ├── Cycle/             # Cognitive cycle implementation
│   ├── Normative/         # Normative calculus engine
│   ├── Scanner/           # Threat detection scanners
│   ├── LLM/              # Language model interfaces
│   └── Util/             # Utility modules
├── config/               # Configuration files
├── www/                  # Web interface assets
├── t/                    # Test suite
└── docs/                # Documentation
```

### Running Tests

```bash
make test
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Code Style

- Follow Raku best practices
- Use descriptive variable and method names
- Include comprehensive documentation
- Write tests for new features

## 🔍 API Reference

### Core Classes

#### `Normative::Agent`
Central ethical reasoning engine that manages endeavours and normative propositions.

```raku
my $agent = Normative::Agent.new;
$agent.init;
my %result = $agent.evaluate-proposition($proposition);
```

#### `Cycle::Cognitive`
Main cognitive processing pipeline coordinator.

```raku
my $cycle = Cycle::Cognitive.new;
my $response = $cycle.process-input($user-input);
```

#### `Scanner::*`
Various threat detection modules:
- `Scanner::PromptLeakage`
- `Scanner::InappropriateContent`
- `Scanner::VulnerableUser`
- `Scanner::NormativeRisk`

### REST API (Web Interface)

The web interface exposes several endpoints:

- `POST /chat` - Submit chat messages for processing
- `GET /status` - System health and diagnostics
- `GET /config` - Configuration information

## 📚 Theoretical Background

TallMountain is based on cutting-edge research in:

- **Normative Calculus**: Formal logical framework for ethical reasoning
- **CogAff Architecture**: Aaron Sloman's cognitive science framework
- **AI Safety**: Comprehensive threat detection and mitigation
- **Deontic Logic**: Logical analysis of normative concepts

For more details, see the papers in the `docs/` directory.

## 🔒 Security Features

- **Multi-layered Threat Detection**: Reactive scanning at multiple levels
- **Normative Compliance**: Ethical reasoning prevents harmful outputs
- **Risk Assessment**: Comprehensive impact analysis before response generation
- **Content Filtering**: Configurable inappropriate content detection
- **Prompt Injection Protection**: Advanced detection of manipulation attempts

## 🐛 Troubleshooting

### Common Issues

1. **"OPENAI_API_KEY environment variable not found"**
   - Set your OpenAI API key in the environment or `.env` file

2. **Dependencies not found**
   - Run `_scripts/install_deps.sh` to install Raku dependencies

3. **Port 10000 already in use**
   - Change the port in `config/default.json` under `chat_ui.chat_ui_port`

4. **Self-diagnostic failures**
   - Check normative proposition configuration in `config/system-endeavours.json`

### Debug Mode

Enable verbose logging by setting the log level in configuration or using debug flags.

## 📄 License

This project is licensed under the MIT License. See the license headers in individual files for details.

## 👥 Credits

- **Author**: seamus@corvideon.ie
- **Architecture**: Based on Aaron Sloman's CogAff framework
- **Language**: Built with [Raku](https://raku.org/)

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines and code of conduct. Areas where help is particularly appreciated:

- Additional LLM provider integrations
- Enhanced threat detection algorithms
- Improved normative reasoning capabilities
- Documentation and examples
- Test coverage improvements

## 📞 Support

For questions, issues, or contributions:
- Open an issue on GitHub
- Check the documentation in the `docs/` directory
- Review the test suite for usage examples

---

*TallMountain represents a new paradigm in AI safety and ethical reasoning, providing a robust framework for building responsible AI agents.*