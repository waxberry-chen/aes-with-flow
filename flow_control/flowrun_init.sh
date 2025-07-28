NEW_PATH="$PWD"

if ! grep -qF "$NEW_PATH" ~/.bashrc; then
    echo "Path '$NEW_PATH' not found. Adding it to ~/.bashrc"
    echo "" >> ~/.bashrc
    echo "# Added by setup script on $(date)" >> ~/.bashrc
    echo "export PATH=\$PATH:$NEW_PATH" >> ~/.bashrc
    echo "Path added successfully."
else
    echo "Path '$NEW_PATH' already exists in ~/.bashrc. No changes made."
fi