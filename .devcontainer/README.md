# Copilot Workspaces - NVM Multi-Version Setup

This development container provides a complete Node.js development environment with NVM (Node Version Manager) supporting multiple Node.js versions.

## 📦 What's Included

- **NVM (Node Version Manager)** - v0.40.6
- **Node.js LTS Versions**:
  - Node 20 (LTS Iron) - **Default**
  - Node 18 (LTS Hydrogen)
  - Node 16 (LTS Gallium)
  - Node Latest
- **Global npm utilities**:
  - npm (latest)
  - pnpm
  - yarn
  - tsx
  - ts-node

## 🚀 Quick Start in Copilot Workspaces

### Open in Copilot Workspaces
1. Go to your fork: `https://github.com/YOUR_USERNAME/nvm`
2. Press `.` to open Copilot Workspaces
3. Wait for the dev container to build (first time takes ~3-5 minutes)
4. Environment is ready when you see terminal prompt

### Switch Node Versions

```bash
# See all installed versions
nvm list

# Switch to specific version
nvm use lts/iron      # Node 20
nvm use lts/hydrogen  # Node 18
nvm use lts/gallium   # Node 16
nvm use node          # Latest

# Check current version
node --version
npm --version
```

### Run Commands with Specific Versions

```bash
# Execute command with specific Node version
nvm run lts/iron -- node app.js
nvm exec lts/hydrogen -- npm run build

# Or switch first, then run
nvm use lts/hydrogen
npm run build
```

### Testing NVM

```bash
# Run NVM tests
npm test

# Run only fast tests
npm run test/fast

# Run tests with specific shell
make test-bash
make test-zsh
```

## 📋 .nvmrc File

The `.nvmrc` file specifies the default Node version for this project:

```
lts/iron
```

When you run `nvm use` without arguments, it will automatically use the version specified in `.nvmrc`.

## 🔧 Environment Variables

Automatically set by NVM:

- `NVM_DIR` - NVM installation directory (`/root/.nvm`)
- `NVM_BIN` - Where node, npm, and global packages are installed
- `NVM_INC` - Node's include directory

## 📚 Useful Commands

```bash
# Install a specific version
nvm install 18.19.0

# List available versions to install
nvm ls-remote

# Set an alias
nvm alias myversion 18.19.0
nvm use myversion

# Uninstall a version
nvm uninstall 18.19.0

# Clear NVM cache
nvm cache clear
```

## 🔄 Reloading NVM

If NVM is not available in your terminal:

```bash
# Reload shell configuration
source ~/.bashrc

# Or restart terminal
exec bash
```

## 📖 More Information

- [NVM Documentation](https://github.com/nvm-sh/nvm)
- [Node.js Release Schedule](https://nodejs.org/en/about/releases/)
- [Dev Container Spec](https://containers.dev/)

## ✨ Customization

To modify the setup:

1. **Add more Node versions**: Edit `setup-nvm.sh` and add `nvm install X.Y.Z`
2. **Change default version**: Modify `nvm alias default <version>` in `setup-nvm.sh`
3. **Add more global packages**: Add to `npm install -g` line in `setup-nvm.sh`
4. **Configure VS Code extensions**: Edit `devcontainer.json` under `customizations.vscode.extensions`

## 🐛 Troubleshooting

**NVM command not found:**
```bash
source /root/.nvm/nvm.sh
```

**Node version not switching:**
```bash
nvm cache clear
nvm list
nvm use lts/iron
```

**Permission denied:**
```bash
chmod +x .devcontainer/setup-nvm.sh
```

---

Enjoy your multi-version Node.js development environment! 🎉
