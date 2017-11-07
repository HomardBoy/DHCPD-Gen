# DHCPD Configurator

### INTRODUCTION :
DHCPD Configurator est un script bash capable de génerer ou d'incrémenter un fichier de configuration DHCP pour le service isc-dhcpd-server.

### Usage:
Le script prend en paramètre un fichier correspondant aux spécificités d'adresses à ajouter au service DHCP, sous la forme suivante : 

              sr:x.x.x.x
              masque:x.x.x.x
              diff:x.x.x.x
      
Si un grand nombre d'adresses sont à traiter, il est recommandé de séparer le fichier d'adresses à traiter en plsuieurs parties, de façon à éviter une mauvaise configuration réseau.

### Tolérance:
La tolérance d'erreur du script dépend forcement des contraintes imposées par le service isc-dhcp-server.
Un système de vérification interne est tout de même présente pour prévenir des erreurs de configurations les plus courantes, ou en cas de non cohérence des adresses renseignés.

### Archivage:
Le script effectue une sauvegarde daté de l'ancien fichier dhcpd.conf à chaque lancements.
Les sauvegardes précédentes ne sont jamais écrasés. Celles-ci sont placés sous "/etc/dhcp"

### Bugs:
Pour l'instant, le script ne fonctionne que lorsque le fichier d'adresses passé en paramètre a un nom ne dépassant pas 4 caractères. Ceci est dû à un décallage entrainé par la manipulations des chaines de caractères, empêchant le script de fonctionner. Il est préférable de réutiliser et d'éditer le fichier d'adresses "test" fournis avec le script. 


