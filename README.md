# Agent Skills Playground

A sandbox for prototyping and demonstrating [Agent Skills](https://agentskills.io) for MATLAB and Simulink work. Skills here are experimental. They may be incomplete, change without notice, or migrate to an official toolkit over time.

> **For official skills, use Agentic Toolkits for MATLAB and Simulink:**
>
> - **[MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit)**: Gives your AI agent the knowledge and context to work efficiently with MATLAB and its toolboxes
> - **[Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit)**: Give your AI coding agent the ability to read, build, edit, and test Simulink® models using Model-Based Design best practices.

## What this repo is for

- **Prototyping**: trying out new skill ideas.
- **Demos**: informal examples of what Agent Skills can do with MATLAB and Simulink.

## Repo layout

```
skills/                      # standalone skills, installed individually
demos/                       # multi-skill bundles with their own tutorial README
```

- **`skills/`** holds single-purpose skills (one folder per skill). Install one at a time.
- **`demos/`** holds bundles: several skills that work together, plus a tutorial README and any supporting files. Use the whole folder.

## Demos

- **[mbse-with-agentic-ai](demos/mbse-with-agentic-ai/)**: agent-driven Model-Based Systems Engineering workflow in MATLAB and Simulink (RFLP methodology). Based on the [MathWorks blog post](https://blogs.mathworks.com/simulink/2026/04/26/model-based-systems-engineering-and-agentic-ai/).
- **[engineering-an-agent-skill](demos/engineering-an-agent-skill/)**: a test-first process for authoring your own Agent Skills, with a meta-skill that walks an agent through the five stages. Based on the [MathWorks blog post](https://blogs.mathworks.com/matlab/2026/05/11/how-to-engineer-an-ai-skill-for-matlab/).

## About Agent Skills

Skills are modular, portable capabilities that work across coding agents:

- **Composable**: skills stack together automatically when needed.
- **Efficient**: skills only load when relevant to the current task.
- **Executable**: skills combine instructions with code, not just text.

See the [Agent Skills specification](https://agentskills.io/specification) for the file format.

## Install a single skill

```bash
git clone https://github.com/matlab/agent-skills-playground.git
cp -r agent-skills-playground/skills/<skill-name> ~/.claude/skills/
```

For Claude.ai (web) and Claude Desktop, zip a skill's directory (with `SKILL.md` at the root) and upload it via **Settings**, then **Capabilities**, then **Upload Skill**.

For other agents, follow the host's instructions for installing user-defined skills.

## Run a demo

```bash
git clone https://github.com/matlab/agent-skills-playground.git
cd agent-skills-playground/demos/<demo-name>
```

Each demo folder is self-contained: it bundles its own skills under `skills/`, a tutorial README, and any supporting files. Open the folder in your agent (for Claude Code, run `claude` from inside the folder) and follow the demo's README.

## Skill development resources

- [Official Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Specification](https://agentskills.io/specification)
- [Agent Skills Repository](https://github.com/agentskills/agentskills)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Claude Code Plugin Guide](https://code.claude.com/docs/en/plugins)

## Related projects

- [matlab/matlab-agentic-toolkit](https://github.com/matlab/matlab-agentic-toolkit): official MATLAB agent skills and live MATLAB session bridge.
- [matlab/simulink-agentic-toolkit](https://github.com/matlab/simulink-agentic-toolkit): official Simulink agent skills and Model-Based Design tooling.
- [matlab/matlab-mcp-core-server](https://github.com/matlab/matlab-mcp-core-server): official MATLAB MCP server for AI applications.
- [matlab/rules](https://github.com/matlab/rules): MATLAB coding rules for AI coding assistants.
- [matlab/prompts](https://github.com/matlab/prompts): curated AI prompts for MATLAB development.
- [matlab/slash-commands](https://github.com/matlab/slash-commands): slash commands for MATLAB development in Claude Code.

## License

Licensed under the MathWorks BSD-3-Clause License. See [LICENSE](LICENSE).

Copyright (c) 2025-2026, The MathWorks, Inc. All rights reserved.

## Community

- **Issues**: [GitHub Issues](https://github.com/matlab/agent-skills-playground/issues)
- **Discussions**: [MATLAB Central GenAI Discussions](https://www.mathworks.com/matlabcentral/discussions/ai)

---

**Supported coding agents**: Agent Skills work with [Claude Code](https://claude.ai/code), [Claude.ai](https://claude.ai), [Cursor](https://cursor.com), [VS Code](https://code.visualstudio.com), [GitHub Copilot](https://github.com), [Gemini CLI](https://geminicli.com), [OpenAI Codex](https://developers.openai.com/codex), [Amp](https://ampcode.com), [Goose](https://block.github.io/goose), [Roo Code](https://roocode.com), and [many more](https://agentskills.io). Feature availability varies by plan and platform.
