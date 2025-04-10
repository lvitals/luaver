# #!/usr/bin/env sh

# # Pega o processo pai
# PARENT_PID=$(ps -p $$ -o ppid=)
# PARENT_NAME=$(ps -p "$PARENT_PID" -o comm=)

# case "$PARENT_NAME" in
#   *fish*) echo "Você está usando: Fish" ;;
#   *zsh*)  echo "Você está usando: Zsh" ;;
#   *bash*) echo "Você está usando: Bash" ;;
#   *)      echo "Shell não identificado: $PARENT_NAME" ;;
# esac

#!/usr/bin/env sh

SHELL_PID=$(ps -p $$ -o ppid=)
SHELL_TYPE=$(ps -p "$SHELL_PID" -o comm=)
SHELL_TYPE_CLEANED=${SHELL_TYPE#-}

echo "Você está usando: $SHELL_TYPE_CLEANED"
