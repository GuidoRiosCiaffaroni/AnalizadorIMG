#!/usr/bin/env bash

# ==============================================================================
# Script Avanzado: Actualización de Ubuntu & Entorno Estilo Google Colab
# Autor: Asistente Data Science & Linux
# ==============================================================================

# Salir inmediatamente si hay un error, variable no definida o fallo en tuberías
set -euo pipefail

# Colores para la interfaz de consola
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

LOG_FILE="/var/log/colab_setup.log"

# Asegurar permisos de superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Por favor, ejecuta este script con privilegios de administrador: sudo ./setup_colab_env.sh${NC}"
    exit 1
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  INICIANDO CONFIGURACIÓN DE ENTORNO DATA SCIENCE    ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. ACTUALIZACIÓN DEL SISTEMA LINUX UBUNTU
echo -e "\n${YELLOW}[1/5] Actualizando repositorios y el sistema Ubuntu...${NC}"
{
    apt-get update -y
    apt-get upgrade -y
    apt-get dist-upgrade -y
    apt-get autoremove -y
    apt-get autoclean -y
} 2>&1 | tee -a "$LOG_FILE"
echo -e "${GREEN}[✔] Sistema Ubuntu actualizado correctamente.${NC}"

# 2. INSTALACIÓN DE HERRAMIENTAS ESENCIALES
echo -e "\n${YELLOW}[2/5] Instalando dependencias base y utilidades...${NC}"
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    htop \
    tree \
    unzip \
    software-properties-common \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-wheel 2>&1 | tee -a "$LOG_FILE"
echo -e "${GREEN}[✔] Herramientas del sistema instaladas.${NC}"

# 3. CREACIÓN DE ESTRUCTURA DE DIRECTORIOS (ESTILO GOOGLE COLAB)
echo -e "\n${YELLOW}[3/5] Creando directorios estilo Google Colab (/content)...${NC}"
BASE_DIR="/content"
mkdir -p "$BASE_DIR"/{datasets/raw,datasets/processed,models,outputs/figures,logs,env,drive}

# Ajustar permisos para que el usuario real (no root) pueda trabajar sin sudo
# Si se ejecutó con sudo, recuperamos el usuario original con $SUDO_USER
TARGET_USER="${SUDO_USER:-$USER}"
chown -R "$TARGET_USER:$TARGET_USER" "$BASE_DIR"
chmod -R 775 "$BASE_DIR"

echo -e "${GREEN}[✔] Estructura creada en ${BASE_DIR}:${NC}"
echo "    ├── datasets/ (raw, processed)"
echo "    ├── models/"
echo "    ├── outputs/ (figures)"
echo "    ├── logs/"
echo "    ├── env/"
echo "    └── drive/"

# 4. VERIFICACIÓN DE HARDWARE (GPU / CUDA)
echo -e "\n${YELLOW}[4/5] Verificando soporte de Hardware (GPU NVIDIA)...${NC}"
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}[✔] Se detectó hardware NVIDIA / CUDA:${NC}"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
else
    echo -e "${YELLOW}[i] No se detectó nvidia-smi. El entorno funcionará en modo CPU.${NC}"
fi

# 5. CONFIGURACIÓN DE ENTORNO VIRTUAL DE PYTHON Y LIBRERÍAS DE DATA SCIENCE
echo -e "\n${YELLOW}[5/5] Configurando entorno virtual Python en $BASE_DIR/env...${NC}"
su - "$TARGET_USER" -c "python3 -m venv $BASE_DIR/env"

# Instalar librerías clave de ciencia de datos dentro del entorno virtual
echo -e "${YELLOW}[i] Instalando librerías base (Pandas, Numpy, Scikit-Learn, Matplotlib, JupyterLab)...${NC}"
su - "$TARGET_USER" -c "
    source $BASE_DIR/env/bin/activate
    pip install --upgrade pip
    pip install numpy pandas scikit-learn matplotlib seaborn jupyterlab
" 2>&1 | tee -a "$LOG_FILE"

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}  ¡CONFIGURACIÓN COMPLETADA CON ÉXITO!              ${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e "Para activar tu entorno virtual de Data Science, ejecuta:"
echo -e "   ${YELLOW}source /content/env/bin/activate${NC}"
echo -e "Para iniciar JupyterLab:"
echo -e "   ${YELLOW}jupyter lab --notebook-dir=/content${NC}"
EOF

chmod +x setup_colab_env.sh
echo -e "\n[✔] ¡Archivo 'setup_colab_env.sh' creado con éxito en tu directorio actual!"