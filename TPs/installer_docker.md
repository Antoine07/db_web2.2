# Installer Docker (pour les TPs) — macOS / Windows / Linux

Ce TP utilise `docker compose` (Postgres, MongoDB, Adminer).

## 1) Installer Docker Desktop

### macOS (Intel / Apple Silicon)

Prérequis :
- macOS récent (idéalement la dernière version stable)
- droits admin pour l'installation

Étapes :
1) Télécharger Docker Desktop : https://www.docker.com/products/docker-desktop/
2) Choisir l'installateur correspondant à votre machine :
   - Apple Silicon : puce M1/M2/M3
   - Intel : anciens Mac
3) Installer l'app (glisser-déposer) puis la lancer
4) Accepter l'installation du “helper” (demande de mot de passe)
5) Attendre l'état “Docker is running” (Docker Desktop doit rester ouvert pendant le TP)

### Windows 10/11 (recommandé : WSL2)

Prérequis :
- Windows 10/11 64-bit
- Virtualisation activée (VT-x / AMD-V)
- droits admin

Remarque (virtualisation) :
- Dans beaucoup de cas c'est déjà activé.
- Vérification rapide : Gestionnaire des tâches → Performance → CPU → “Virtualisation : Activée”.
- Si c'est “Désactivée”, il faut l'activer dans le BIOS/UEFI pour que WSL2/Docker fonctionnent.

Étapes (WSL2) :
1) Installer WSL (si besoin) :
   - Ouvrir PowerShell en admin et lancer : `wsl --install`
   - Redémarrer si demandé
2) Installer Docker Desktop : https://www.docker.com/products/docker-desktop/
3) Pendant l'installation, activer **Use WSL 2 instead of Hyper-V** (recommandé)
4) Ouvrir Docker Desktop → Settings → Resources → WSL integration → activer la distro WSL utilisée (ex: Ubuntu)
5) Attendre l'état “Docker is running”

Notes :
- Si `wsl` n'existe pas : Windows n'est pas à jour (mettre à jour Windows).
- Si Docker ne démarre pas : vérifier “Virtual Machine Platform” + “Windows Subsystem for Linux” dans “Turn Windows features on or off”.
- Si vous utilisez WSL, lancez les commandes dans un terminal WSL (Ubuntu, etc.) pour une meilleure compatibilité/perf.

### Linux

Option A (simple) : Docker Desktop (selon distribution)  
Option B (classique) : Docker Engine + Docker Compose

Documentation officielle : https://docs.docker.com/engine/install/

Après installation, vérifiez que votre user peut exécuter Docker (groupe `docker`) :
https://docs.docker.com/engine/install/linux-postinstall/

Étapes “Docker Engine” (résumé) :
1) Installer Docker Engine pour votre distro (Ubuntu / Debian / Fedora…) via la doc officielle
2) Démarrer le service :
   - `sudo systemctl enable --now docker`
3) Autoriser votre user :
   - `sudo usermod -aG docker $USER`
   - déconnectez/reconnectez-vous (ou redémarrez) pour que le groupe soit pris en compte
4) Vérifier : `docker ps`

## 2) Vérifier l'installation

Dans un terminal :

```bash
docker --version
docker compose version
```

Vous devez voir une version s'afficher (pas “command not found”).

## 3) Vérifier que Docker démarre

1) Ouvrir Docker Desktop et attendre qu'il affiche “Docker is running”
2) Tester :

```bash
docker ps
```

Si vous voyez une erreur du type “Cannot connect to the Docker daemon”, Docker n'est pas démarré.

## 4) Problèmes fréquents

- **Port déjà utilisé** :
  - Dans ce cours, Postgres est mappé en `5433` pour éviter un conflit avec un Postgres local sur `5432`.
  - Si un port est pris, modifiez le mapping dans `docker-compose.yml`.
- **Windows + WSL2** :
  - Assurez-vous que Docker Desktop a bien le backend WSL2 activé.
  - Si vous travaillez dans WSL, placez le projet dans le filesystem WSL (ex: `~/projects`) plutôt que dans `C:\...` pour de meilleures performances.
- **Linux : permission denied sur le daemon** :
  - Vérifiez que le service tourne : `sudo systemctl status docker`
  - Vérifiez que votre user est dans le groupe `docker` : `groups | rg docker` (ou `grep`)
