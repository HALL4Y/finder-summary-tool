#!/bin/zsh
# ------------------------------------------------------------------
# V3.0 - Alignement millimétré & Unités intelligentes (Ko/Mo)
# ------------------------------------------------------------------

start_epoch=$(date +%s)

first_item="$1"
parent_dir=$(dirname "$first_item")
parent_name=$(basename "$parent_dir")
nb_total=$#

# Estimation temps
est_secs=$(echo "$nb_total * 0.1" | bc) 
est_secs_int=${est_secs%.*}
if [[ -z "$est_secs_int" || "$est_secs_int" -eq 0 ]]; then est_secs_int=1; fi
estimated_time="${est_secs_int} sec."

# Notification début
title="Génération du listing..."
msg="$nb_total éléments dans : $parent_name"
osascript -e "display notification \"$msg\" with title \"$title\""

date_str=$(date +"%Y%m%d")
temp_dir="$HOME/listing_temp"
mkdir -p "$temp_dir"

# Noms fichiers
listing_base="listing_${date_str}_${parent_name}"
listing_ext=".txt"
listing_final_path="$parent_dir/${listing_base}${listing_ext}"

i=1
while [ -e "$listing_final_path" ]; do
  listing_final_path="$parent_dir/${listing_base}_$i$listing_ext"
  i=$((i+1))
done

listing_temp_path="$temp_dir/$(basename "$listing_final_path")"

# --- CONFIGURATION STRICTE DU TABLEAU ---
# %-20s = Colonne de 20 chars alignée à gauche (Pour "Date modification")
# %-10s = Colonne de 10 chars alignée à gauche (Pour "Poids")
FMT="%-20s | %-10s | %s\n"

# La ligne de séparation doit correspondre EXACTEMENT aux largeurs ci-dessus
# 20 tirets + 1 espace + | + 1 espace + 10 tirets + 1 espace + | + le reste
SEP="---------------------|------------|--------------------------------------------------"

# En-tête du fichier
{
    echo "=== LISTING : $parent_name ==="
    echo "Généré le : $(date '+%d/%m/%Y à %H:%M')"
    echo ""
    # On utilise le MEME format pour le titre que pour les données
    printf "$FMT" "Date modification" "Poids" "Nom"
    echo "$SEP"
} > "$listing_temp_path"

total_files=0
total_size_bytes=0
oldest_date=""
current_date_epoch=$(date +%s)

# Boucle principale
for item in "$@"; do
  if [[ -e "$item" ]]; then
    mod_date=$(stat -f "%Sm" -t "%d/%m/%Y %H:%M" "$item" 2>/dev/null || echo "N/A")
    mod_epoch=$(stat -f "%m" "$item")

    if [[ -f "$item" ]]; then
      size_bytes=$(stat -f "%z" "$item")
      
      # --- LOGIQUE INTELLIGENTE Ko / Mo ---
      if (( size_bytes < 1048576 )); then
         # En dessous de 1 Mo -> Affichage en Ko (Entier)
         size_kb=$(( size_bytes / 1024 ))
         if (( size_kb == 0 )); then size_kb=1; fi # Minimum 1 Ko affiché
         size_display="${size_kb} Ko"
      else
         # Au dessus de 1 Mo -> Affichage en Mo (2 décimales)
         size_mo_item=$(echo "scale=2; $size_bytes/1048576" | bc)
         size_display="${size_mo_item} Mo"
      fi

      total_files=$((total_files+1))
      total_size_bytes=$((total_size_bytes + size_bytes))
    else
      size_display="[DOSSIER]"
    fi

    item_name=$(basename "$item")

    if [[ -z "$oldest_date" || "$mod_epoch" -lt "$oldest_date" ]]; then
      oldest_date=$mod_epoch
    fi

    # Écriture de la ligne
    printf "$FMT" "$mod_date" "$size_display" "$item_name" >> "$listing_temp_path"
  fi
done

# Pied de page (Fermeture du tableau)
echo "$SEP" >> "$listing_temp_path"

# --- BLOC RÉSUMÉ (Hors tableau) ---
age_seconds=$((current_date_epoch - oldest_date))
age_days=$((age_seconds / 86400))

# Calcul du total final en Mo pour le résumé
total_size_mo_final=$(echo "scale=2; $total_size_bytes/1048576" | bc)

{
    echo ""
    echo "📊 STATISTIQUES"
    echo "----------------"
    echo "Total fichiers : $total_files"
    echo "Poids global   : ${total_size_mo_final} Mo"
    echo "Ancienneté max : $age_days jours"
} >> "$listing_temp_path"

# Finalisation
mv "$listing_temp_path" "$listing_final_path"
rmdir "$temp_dir" 2>/dev/null || true

# Notification fin
title="Listing terminé"
msg="Fichier créé : $(basename "$listing_final_path")"
osascript -e "display notification \"$msg\" with title \"$title\""
echo "$listing_final_path"
