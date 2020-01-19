-- The default locale, which is in the English language.
local L = LibStub("AceLocale-3.0"):NewLocale("RareTrackerVale", "frFR")
if not L then return end

L["seen at"] = "vu à"
L["<RTV> %s has died"] = "<RTV> %s est mort."
L["Click on the squares to add rares to your favorites."] = "Cliquer sur les carrés pour ajouter des rares à vos favoris."
L["Click on the squares to announce rare timers."] = "Cliquer sur les carrés pour annoncer les timers."
L["Left click: report to general chat"] = "Clique gauche : annoncer sur le canal général."
L["Control-left click: report to party/raid chat"] = "Control-clique gauche : annoncer au groupe/raid."
L["Alt-left click: report to say"] = "Alt-clique gauche : annoncer en /dire"
L["Right click: set waypoint if available"] = "Clique droit : placer un waypoint si possible."
L["Reset your data and replace it with the data of others."] = "Réinitialiser vos données et les remplace avec celles des autres."
L["Note: you do not need to press this button to receive new timers."] = "Note : vous n'avez pas besoin d'utiliser ce bouton pour recevoir les nouveaux timers."
L["<RTV> Resetting current rare timers and requesting up-to-date data."] = "<RTV> Remise-à-zéro des timers actuels et requête de données à jour."
L["<RTV> Please target a non-player entity prior to resetting, such that the addon can determine the current shard id."] = "<RTV> Veuillez sélectionner une entité non joueuse avant la remise-à-zéro, afin de permettre à l'addon de déterminer le shard id actuel."
L["<RTV> The reset button is on cooldown. Please note that a reset is not needed to receive new timers. If it is your intention to reset the data, please do a /reload and click the reset button again."] = "<RTV> Le bouton de remise-à-zéro est en recharge. Il est à noté qu'un reset n'est pas nécessaire pour recevoir les nouveaux timers. Si vous voulez effectivement réinitialiser les dnnées, veuillez faire un /reload puis cliquer à nouveau sur le bouton de reset."
L["Favorite sound alert"] = "Son d'alerte favori."
L[" Show minimap icon"] = " Afficher l'icone de la minimap."
L["Show or hide the minimap button."] = "Montrer ou masquer l'icone de la minimap."
L[" Enable communication over part/raid channel"] = " Activer la communication via le canal de groupe/raid."
L["Enable communication over party/raid channel, to support CRZ functionality while in a party or raid group."] = "Activer la communication via le canal de groupe/raid afin de permettre les fonctionnalité CRZ lorsque vous êtes groupés ou en raid."
L[" Enable debug mode"] = " Activer le mode debug."
L["Set the scale of the rare window."] = "Définir l'échelle de la fenêtre de rare."
L["Rare window scale "] = "Échelle de la fenêtre de rare "
L["Reset Favorites"] = "Ré-initialiser les favoris"
L["Reset Blacklist"] = "Ré-initialiser les ignorés"
L["<RTV> Favorites cannot be hidden."] = "<RTV> Les favoris ne peuvent pas être cachés."
L["Disable All"] = "Désactiver tous"
L["Enable All"] = "Activer tous."
L["Reset Order"] = "Remise-à-zéro de l'ordre."
L["Rare ordering/selection"] = "Ordre/sélection des rares."
L["Shard ID: Unknown"] = "Shard ID: Inconnu"
L["Shard ID: "] = "Shard ID: "
L["<RTV> %s (%s%%) seen at ~(%.2f, %.2f)"] = "<RTV> %s (%s%%) vu à ~(%.2f, %.2f)"
L["<RTV> %s (%s%%) seen at ~(N/A)"] = "<RTV> %s (%s%%) vu à ~(N/A)"
L["<RTV> %s was last seen ~%s minutes ago"] = "<RTV> %s vu pour la dernière fois il y a ~%s minutes"
L["<RTV> %s seen alive, vignette at ~(%.2f, %.2f)"] = "<RTV> %s vu en vie à la position ~(%.2f, %.2f)"
L["<RTV> %s seen alive (combat log)"] = "<RTV> %s vu en vie (log de combat)"
L["Left-click: hide/show RTV"] = "Clique-gauche : montrer ou masquer RTV"
L["Right-click: show options"] = "Clique-droit : afficher les options."
L["<RTV> Moving to shard "] = "<RTV> Moving to shard "
L["<RTV> Removing cached data for shard "] = "<RTV> Suppression des données en cache pour le shard "
L["<RTV> Restoring data from previous session in shard "] = "<RTV> Restauration des données de la session précédente pour le shard."
L["<RTV> Requesting rare kill data for shard "] = "<RTV> Requête des données pour les morts de rare pour le shard "
L["<RTV> Your version or RareTrackerVale is outdated. Please update to the most recent version at the earliest convenience."] = "<RTV> Votre version de RareTrackerVale n'est pas à jour. Veuillez faire la mise-à-jour au moment qui vous conviendra."
L["<RTV> Failed to register AddonPrefix 'RTV'. RTV will not function properly."] = "<RTV> Échec de réservation du préfixe d'addon 'RTV'. RTV ne pourra pas fonctionner convenablement."