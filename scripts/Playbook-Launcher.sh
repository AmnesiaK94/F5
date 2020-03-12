#!/bin/bash
# JBN 11/03/2020
#Verification que le fichier .json existe et que celui-ci à la bonne syntaxe
#Découpe le fichier en x.json dans une repertoire temporaire 
#Executer le playbook ansible-playbook avec le fichier json en entrée avec tous les json dans le dossier.

#set -x

RED='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
NC='\033[0m' # No Color

KO="${RED}[ KO ]${NC}"
OK="${G}[ OK ]${NC}"


JSONREF=F5_PEPS_REC_OP
JSONPATH=../files/
JSONFILE=$JSONREF.json
JSONFP=$JSONPATH$JSONFILE
JSONTEMPDIR=../files/$JSONREF-TEMP-JSON/
PB=../tasks/main.yml
INV=../hosts




echo ""
echo "Positionnement du script Bash dans ./script/"
echo ""


parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"


if test -f "$JSONFP"; then
  echo ""
  echo "Le fichier '$JSONFILE' existe"
  echo ""
  cat $JSONFP | jq '.'
  if [ $? -ne 0 ]; then
    echo -e "$KO Erreur de syntaxe dans le fichier json"
    exit 1
  else
    echo -e "$OK La syntaxe du fichier Json est correct"
  fi
  echo ""
  echo -e "Creation du repertoire $JSONTEMPDIR"
  mkdir -p $JSONTEMPDIR
  echo -e "Decoupage du fichier Json"
  cat $JSONFP  | jq -c '.[] | .[]' > $JSONTEMPDIR$JSONFILE
  awk '{print > ( FILENAME"."NR ) }'  $JSONTEMPDIR$JSONFILE
  rm -rf $JSONTEMPDIR$JSONFILE
  echo -e "Liste des fichiers Json générés dans "$JSONTEMPDIR" :"
  echo ""
  ls  $JSONTEMPDIR | grep json
  echo ""
  echo -e "Liste des Noms technique de VIP qui vont être crées:"
  echo ""
  cat $JSONFP | jq -r '.[] | .[].vsid'
  echo ""
  
  TMPJSONVIP=$JSONTEMPDIR*
  for j in $TMPJSONVIP
  do
  Virtual_name=`cat $j | jq -r '.vsid'`
  echo ""
  echo ""
  echo -e "${Y}##################################################################################################################################################${NC}"
  echo -e "${Y}Ajustement pour la VIP : vs_$Virtual_name${NC}"
  echo -e "${Y}Launching: [ ansible-playbook $PB -e "@$j" -i $INV}]${NC}"
  echo -e "${Y}##################################################################################################################################################${NC}"
  ansible-playbook $PB -e "@$j" -i $INV
    if [ $? -ne 0 ]; then
      echo -e "$KO Le playbook s'est mal terminé pour le fichier Json : $j"
      echo -e "$KO Sortie du script"
      exit 1
    else
      echo -e "$OK La playbook s'est terminé avec succès pour le fichier Json : $j"
    fi
   done
 
else
  echo -e "$KO Le fichier '$JSONFILE' n'existe pas"
fi




#cat F5_PEPS_REC_OP_V2.json | jq -r '.F5_PEPS_REC_OPR | to_entries[0].value.name'

