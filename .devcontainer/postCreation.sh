# # nvm

NVM_DIR="/workspaces/nvm"
echo 'export ${NVM_DIR}' >> "${HOME}/.bashrc"
echo '[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"  # This loads nvm' >> "${HOME}/.bashrc"
echo '[ -s "${NVM_DIR}/bash_completion" ] && . "${NVM_DIR}/bash_completion" # This loads nvm bash_completion' >> "${HOME}/.bashrc"

# nodejs and tools
source ${NVM_DIR}/nvm.sh
nvm install node
npm install -g doctoc urchin eclint dockerfile_lint
npm install --prefix "${NVM_DIR}"

echo hi >> $NVM_DIR/test