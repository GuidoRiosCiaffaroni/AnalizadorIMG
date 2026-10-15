#!/bin/bash

####################################################################################################################
read -rsp $'Presione cualquier tecla o espere 5 segundos para continuar  \n' -n 1 -t 2;
echo -e "\nIniciando proceso de actualización y subida..."

# 1. Definir variables para fecha y tiempo
date_stamp=$(date +"%Y_%m_%d_%H_%M_%S")

# 2. Agregar todos los cambios locales al área de preparación
echo "=> Ejecutando: git add ."
git add .

# 3. Crear el commit local con la marca de tiempo
echo "=> Ejecutando: git commit -m \"$date_stamp\""
git commit -m "$date_stamp" || echo "No hay cambios nuevos para commitear."

# 4. Asegurar la rama principal main
echo "=> Ejecutando: git branch -M main"
git branch -M main

# 5. INTEGRACIÓN CRÍTICA: Traer los cambios remotos usando --rebase antes del push
# Esto resuelve el error '[rejected] (fetch first)' trayendo lo que está en GitHub 
# y acomodando tu commit actual limpiamente al final de la línea de tiempo.
echo "=> Ejecutando: git pull --rebase origin main"
git pull --rebase origin main

# 6. Subir los cambios actualizados a GitHub de forma segura
echo "=> Ejecutando: git push -u origin main"
git push -u origin main

echo "¡Todo sincronizado con éxito para el taller!"