#!/bin/zsh
# ------------------------------------------------------------------
# Ce script est le coeur du fichier FinderSummary.workflow.
# Il est exécuté par Automator lors de l'action rapide.
# ------------------------------------------------------------------

start_epoch=$(date +%s)

first_item="$1"
parent_dir=$(dirname "$first_item")
parent_name=$(basename "$parent_dir")
nb_total=$#

# Estimation temps
est_secs=$(echo "$nb_total * 0.2" | bc)
est_secs_int=${est_secs%.*}
estimated_time="${est_secs_int} seconde(s) approx."

# Notification début
title="Listing en cours"
subtitle="Dossier : $parent_name"
msg="Éléments : $nb_total — Durée estimée : $estimated_time"
osascript -e "display notification \"$msg\" with title \"$title\" subtitle \"$subtitle\""

date_str=$(date +"%Y%m%d")

# Dossier temporaire
temp_dir="$HOME/listing_temp"
mkdir -p "$temp_dir"

# Noms fichiers
listing_base="listing_${date_str}_${parent_name}"
listing_ext=".txt"
listing_final_path="$parent_dir/${listing_base}${listing_ext}"

# Gestion doublons
i=1
while [ -e "$listing_final_path" ]; do
  listing_final_path="$parent_dir/${listing_base}_$i$listing_ext"
  i=$((i+1))
done

listing_file=$(basename "$listing_final_path")
listing_temp_path="$temp_dir/$listing_file"

# En-tête
echo "=== Listing de la sélection dans : $parent_name ===" > "$listing_temp_path"
echo "Généré le : $(date '+%d/%m/%Y à %H:%M')" >> "$listing_temp_path"
echo "-----------------------------------------------------" >> "$listing_temp_path"
echo "" >> "$listing_temp_path"
echo "Date modification     | Poids (Mo) | Nom" >> "$listing_temp_path"
echo "----------------------|------------|------------------------------" >> "$listing_temp_path"

total_files=0
total_size=0
oldest_date=""
current_date_epoch=$(date +%s)

# Boucle principale
for item in "$@"; do
  if [[ -e "$item" ]]; then
    mod_date=$(stat -f "%Sm" -t "%d/%m/%Y %H:%M" "$item" 2>/dev/null || echo "N/A")
    mod_epoch=$(stat -f "%m" "$item")

    if [[ -f "$item" ]]; then
      size_bytes=$(stat -f "%z" "$item")
      size_mo=$(echo "scale=2; $size_bytes/1024/1024" | bc)
      size_str=$(printf "%.2f" "$size_mo")
      total_files=$((total_files+1))
      total_size=$(echo "$total_size + $size_mo" | bc)
    else
      size_str="[DOSSIER]"
    fi

    item_name=$(basename "$item")

    if [[ -z "$oldest_date" || "$mod_epoch" -lt "$oldest_date" ]]; then
      oldest_date=$mod_epoch
    fi

    printf "%-19s | %-10s | %s\n" "$mod_date" "$size_str" "$item_name" >> "$listing_temp_path"
  fi
done

# Calcul stats finales
age_seconds=$((current_date_epoch - oldest_date))
age_days=$((age_seconds / 86400))
age_months=$((age_days / 30))
age_years=$((age_days / 365))

echo "----------------------|------------|------------------------------" >> "$listing_temp_path"
age_str="${age_days} jour(s)\n${age_months} mois\n${age_years} années"
printf "%-19b | %-10s | %s\n" "$age_str" "$(printf "%.2f" "$total_size")" "Nombre de fichiers : $total_files" >> "$listing_temp_path"

# Finalisation
mv "$listing_temp_path" "$listing_final_path"
rmdir "$temp_dir" 2>/dev/null || true

end_epoch=$(date +%s)
elapsed=$((end_epoch - start_epoch))

# Notification fin
if (( elapsed < 60 )); then
  real_time="${elapsed} s"
else
  mins=$((elapsed / 60))
  secs=$((elapsed % 60))
  real_time="${mins} min ${secs} s"
fi

title="Listing terminé"
subtitle="Dossier : $parent_name"
msg="Fichier : $listing_final_path — Durée réelle : $real_time"
osascript -e "display notification \"$msg\" with title \"$title\" subtitle \"$subtitle\""
echo "$listing_final_path"
