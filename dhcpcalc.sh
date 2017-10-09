#!/bin/bash

#Déclaration des fonctions :
TestIP1()
{
    #Isole octets de l'IP
    subnet2=$1
    oc1=${subnet2%%.*}
    subnet2=${subnet2#*.*}
    oc2=${subnet2%%.*}
    subnet2=${subnet2#*.*}
    oc3=${subnet2%%.*}
    subnet2=${subnet2#*.*}
    oc4=${subnet2%%.*}

    #Isole octets du masque
    masque2=$2
    m1=${masque2%%.*}
    masque2=${masque2#*.*}
    m2=${masque2%%.*}
    masque2=${masque2#*.*}
    m3=${masque2%%.*}
    masque2=${masque2#*.*}
    m4=${masque2%%.*}

    #Récupère les 4 octets de l'ip entrée
    debut2=$3
    deb1=${debut2%%.*}
    debut2=${debut2#*.*}
    deb2=${debut2%%.*}
    debut2=${debut2#*.*}
    deb3=${debut2%%.*}
    debut2=${debut2#*.*}
    deb4=${debut2%%.*}

    #Test d'IP cohérentes (Pas de d'adresse de début = adresse réseau)
        if [ "$3" = "$subnet" ]
            then
                    echo $red " "
                    echo "Entrée non valide, veuillez recommencer ... "
                    echo "La première adresse de l'étendu ne peut pas être l'adresse réseau de la plage d'adresses !"
                    rm dhcpdbis.conf
                    exit 1
        fi

        #Tests d'IP cohérentes (Octets pas plus grads que 255)
                if [ "$deb1" -ge "$max" ]
                then
                    echo $red " "
                    echo "Entrée non valide, veuillez recommencer ... "
                    echo "Le premier octet ne peut pas être superieur à 255 ..."
                    rm dhcpdbis.conf
                    exit 1
                else
                    if [ "$deb2" -ge "$max" ]
                    then
                    echo $red " "
                    echo "Entrée non valide, veuillez recommencer ... "
                    echo "Le deuxième octet ne peut pas être superieur à 255 ..."
                    rm dhcpdbis.conf
                    exit 1
                    else
                        if [ "$deb3" -ge "$max" ]
                        then
                        echo $red " "
                        echo "Entrée non valide, veuillez recommencer ... "
                        echo "Le troisième octet ne peut pas être superieur à 255 ..."
                        rm dhcpdbis.conf
                        exit 1
                        else
                            if [ "$deb4" -ge "$max" ]
                            then
                            echo $red " "
                            echo "Entrée non valide, veuillez recommencer ... "
                            echo "Le dernier octet ne peut pas être superieur à 255 ..."
                            rm dhcpdbis.conf
                            exit 1
                            fi
                        fi
                    fi
                fi

#Test d'IP cohérentes n°3 (Respect du masque)
                if [ $m1 = 255 ]
                then
                    #Masque /8
                    if [ $deb1 = $oc1 ]
                    then
                        if [ $m2 = 255 ]
                        then
                        #Masque /16
                             if [ $deb2 = $oc2 ]
                             then
                                if [ $m2 = 255 ]
                                  then
                                  #Masque /24
                                    if [ $deb3 != $oc3 ]
                                    then
                                      echo $red " "
                                      echo "Entrée non valide, veuillez recommencer ... "
                                      echo "L'adresse IP doit être sous la forme : " $oc1"."$oc2"."$oc3".***"
                                      rm dhcpdbis.conf
                                      exit 1
                                    fi
                                  fi
                                else
                                 echo $red " "
                                 echo "Entrée non valide, veuillez recommencer ... "
                                 echo "L'adresse IP doit être sous la forme : " $oc1"."$oc2".***.***"
                                 rm dhcpdbis.conf
                                 exit 1
                            fi
                        fi
                    else
                    echo $red " "
                    echo "Entrée non valide, veuillez recommencer ... "
                    echo "L'adresse IP doit être sous la forme : " $oc1".***.***.***"
                    rm dhcpdbis.conf
                    exit 1
                    fi
                fi
}

#Sauvegarde aucien fichier de configuration
cp /etc/dhcp/dhcpd.conf /etc/dhcpd.conf.bak

okegreen='\033[92m'
RESET="\033[00m"
red='\e[1;31m'

clear
max="255"

echo $okegreen " "
echo "Chemin relatif jusqu'au fichier de configuration à interpréter :"
echo $RESET " "
read nom

echo $okegreen " "
echo "Merci d'indiquer l'adresse du serveur DNS :"
echo $RESET " "
read DNSadd

echo $okegreen " "
echo "Merci d'indiquer le nom de domaine :"
echo $RESET " "
read DomaineName

#Configuration initial du fichier de conf
touch dhcpdbis.conf
echo "option domain-name\"$DomaineName\""";" >> dhcpdbis.conf
echo "option domain-name servers" $DNSadd";">> dhcpdbis.conf
echo "authoritative;" >> dhcpdbis.conf

if [ -f $nom ]
then
#Le fichier existe

    #Nombre de lignes
    nbligne=$(wc -l $nom)
    echo $nbligne > temp.txt
    num=$(sed 's/test//' temp.txt)
    rm temp.txt

    #Nombre d'adresses à traiter
    nbaddress=$(($num/3))
    echo "DEBUG : NUMBER OF ADDRESS : " $nbaddress
    nbaddress2=$(($nbaddress - 1))

        #Boucle qui parcours les différentes adresses à traiter
        for k in `seq 0 $nbaddress2`;
        do

            #Isole l'adresse réseau
            positionaddress=$((($k*3)+1))
            positionmasque=$(($positionaddress+1))
            positionbroadcast=$(($positionaddress+2))

            #Récupère l'adresse réseau + le masque du ségment concerné et l'ajoute au fichier de configuration
            #Récupère adresse réseau
            subnet2=$(head -n $positionaddress $nom | tail -n 1)
            echo $subnet2 > temp.txt
            subnet=$(sed 's/sr://' temp.txt)
            #Récupère masque
            masque2=$(head -n $positionmasque $nom | tail -n 1)
            rm temp.txt
            echo $masque2 > temp.txt
            masque=$(sed 's/masque://' temp.txt)
            #Ajout de l'adresse et du masque au fichier de conf
            echo "" >> dhcpdbis.conf
            echo "subnet" $subnet "netmask" $masque "{" >> dhcpdbis.conf
            rm temp.txt

            #Range début
            echo $okegreen " "
            echo "Merci d'indiquer l'adresse de début de l'étendue" $subnet ":"
            echo $RESET " "
            read debut

            #Appel fonction de tests pour l'adresse de début
            TestIP1 $subnet $masque $debut

            #Range fin
            echo $okegreen " "
            echo "Merci d'indiquer l'adresse de fin de l'étendue" $subnet ":"
            echo $RESET " "
            read fin
            echo "range" $debut $fin ";" >> dhcpdbis.conf
            echo "option domain-name-servers" $DNSadd";" >> dhcpdbis.conf
            echo "option domain-name\"$DomaineName\""";" >> dhcpdbis.conf

            #Appel fonction de tests pour l'adresse de début
            TestIP1 $subnet $masque $fin

            #Gateway
            echo $okegreen " "
            echo "Merci d'indiquer l'adresse de passerelle pour le réseau " $subnet ":"
            echo $RESET " "
            read gateway
            echo "option routers" $gateway ";" >> dhcpdbis.conf

            #Appel fonction de tests pour l'adresse de passerelle
            TestIP1 $subnet $masque $gateway

            #Broadcast
            Broadcast2=$(head -n $positionbroadcast $nom | tail -n 1)
            echo $Broadcast2 > temp.txt
            Broadcast=$(sed 's/diff://' temp.txt)
            rm temp.txt
            echo "option broadcast-address" $Broadcast";" >> dhcpdbis.conf

            #Lease
            echo "default-lease-time 600;" >> dhcpdbis.conf
            echo "max-lease-time 7200;" >> dhcpdbis.conf
            echo "}" >> dhcpdbis.conf
            echo "" >> dhcpdbis.conf

            #Vérification
            echo "VERIFICATION - ADDRESS DNS : " $DNSadd
            echo "VERIFICATION - NOM DE DOMAINE : " $DomaineName
            echo "VERIFICATION - MASQUE n°" $k " : " $masque
            echo "VERIFICATION - ADDRESS RESEAU n°" $k " : " $subnet
            echo "VERIFICATION - ADDRESS DEBUT : " $debut
            echo "VERIFICATION - ADDRESS FIN : " $fin
            echo "VERIFICATION - ADDRESS BROADCAST :" $Broadcast

        done

        #Remplacement du fichier de configuration
        cp dhcpdbis.conf /etc/dhcp/dhcpd.conf

else 
#Le fichier n'existe pas
    echo "Ouuups ..."
    echo "Le fichier à interpréter ne semble pas exister !"
    echo "Vérifiez l'emplacement et l'orthographe ..."
fi
