#!/bin/bash
#Verification que le fichier .json existe et que celui-ci à la bonne syntaxe
#Découpe le fichier en x.json dans une repertoire temporaire 
#Recuperation des clé "NAME" de chaque fichier json et verifier si le fichier json de la VIP existe.
#Si le nom existe déja ne rien faire
#Si le nom d'existe pas ne rien faire 
#Si le nom existe mais que la clé n'est pas existance dans la demande, copier le fichier json manquant et insérer le state absent.
#Compter le nombre de fichier json à traiter et stocket ce nombre dans une variable vip_number
#Executer le playbook ansible-playbook avec le fichier json en entrée avec tous les json dans le dossier.
#L'execution de chaque playbook stock le fichier json de variable de la VIP dans la BDD si le playbook s'est bien executé.
#set -x
JSONREF=F5_PEPS_REC_OP
JSONPATH=../files/
JSONFILE=$JSONREF.json
JSONFP=$JSONPATH$JSONFILE
JSONTEMPDIR=../files/$JSONREF-TEMP-JSON/


echo $JSONPATH
echo $JSONFILE
echo $JSONFP
echo $JSONTEMPDIR
echo $JSONTEMPDIR$JSONFILE

if test -f "$JSONFP"; then
  echo "Le fichier '$JSONFILE' existe"
  cat $JSONFP | jq '.'> /dev/null
  if [ $? -ne 0 ]; then
    echo "erreur de syntaxe dans le fichier json"
  else
    echo "La syntaxe du fichier Json est correct"
  fi
  echo "Creation du repertoire $JSONTEMPDIR"
  mkdir -p $JSONTEMPDIR
  echo "Decoupage du fichier Json"
  cat $JSONFP  | jq -c '.[] | .[]' > $JSONTEMPDIR$JSONFILE
  awk '{print > ( FILENAME"."NR ) }'  $JSONTEMPDIR$JSONFILE
  rm -rf $JSONTEMPDIR$JSONFILE
  echo "Liste des fichiers Json générés dans "$JSONTEMPDIR" :"
  ls  $JSONTEMPDIR | grep json
  echo "Liste des Noms technique de VIP qui vont être créees:"
  cat $JSONFP | jq -r '.[] | .[].name '
  
  TMPJSONVIP=$JSONTEMPDIR*
  for j in $TMPJSONVIP
  do
  echo "Processing $j file..."
  ls $j
  done

 
else
  echo "Le fichier '$JSONFILE' n'existe pas"
fi


#cat F5_PEPS_REC_OP_V2.json | jq -r '.F5_PEPS_REC_OPR | to_entries[0].value.name'

