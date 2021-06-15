<p align="center">
    <img src="https://raw.githubusercontent.com/xthursdayx/docker-templates/master/images/yacreader-icon.png" alt="" width="150"/>  
</p>

[![Docker Build and Publish](https://github.com/xthursdayx/yacreaderlibrary-server-docker/actions/workflows/docker-build-and-publish.yml/badge.svg)](https://github.com/xthursdayx/yacreaderlibrary-server-docker/actions/workflows/docker-build-and-publish.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/xthursdayx/yacreaderlibrary-server-docker)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/xthursdayx/yacreaderlibrary-server-docker/p7zip?label=p7zip%20image%20size)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/xthursdayx/yacreaderlibrary-server-docker/unarr?label=unarr%20image%20size)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/xthursdayx/yacreaderlibrary-server-docker?sort=semver)

# YACReaderLibrary Server Docker

Headless version of the [YACReaderLibraryServer](https://github.com/YACReader/yacreader/tree/develop/YACReaderLibraryServer). 

[YACReader](https://www.yacreader.com/) is the best comic reader and comic manager available, with support for cbr, cbz, zip, and rar comic files. 

YACReaderLibraryServer makes it easy to run a home comics server to serve your comics to any device running a YACReader client (including Windows, MacOS, Linux, and iOS).

## Setup Instructions:

You can choose to install one of two versions of the YACReaderLibraryServer docker image, which have two different compression backends - either [p7zip](https://sourceforge.net/projects/p7zip/files/p7zip/16.02/) or [unarr](https://github.com/selmf/unarr). These two versions are handled via the image tags `xthursdayx:yacreaderlibrary-server-docker:pzip` or `xthursdayx:yacreaderlibrary-server-docker:unarr`

For the best stability and genberal quality, it is recommended that you install YACReaderLibraryServer with `unarr`, which is the default installation, however there is some evidence that YACReaderLibraryServer compiled with `p7zip` may scan and update your comics library(s) faster than the version complied with unarrr, so the choice is yours.

Here are some examples to help you get started creating a container. If you are an UNRAID user you can access my [UNRAID YACReaderLibraryServer template](https://raw.githubusercontent.com/xthursdayx/docker-templates/master/yacserver.xml) in Community Apps.

### Docker CLI

```bash
docker run -d \
  --name=YACReaderLibraryServer \
  -e PUID=99 \
  -e PGID=100 \
  -e TZ=America/New_York \
  -p 8080:8080 \
  -v /path/to/config:/config \
  -v /path/to/comic:/comics \
  --restart unless-stopped \
  xthursdayx/yacreaderlibrary-server-docker:[tag]
```

### docker-compose

```yaml
---
version: "3"
services:
  yacreaderlibrary-server-docker:
    container_name: YACReaderLibraryServer
    image: xthursdayx/yacreaderlibrary-server-docker:[tag]
    environment:
      - PUID=99
      - PGID=100
      - TZ=America/New_York
    volumes:
      - /path/to/config:/config
      - /path/to/comics:/comics
    ports:
      - 8080:8080
    restart: unless-stopped
```

### Parameters

Container images are configured using parameters passed at runtime (such as those listed above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container. You can change the external/host port and volume mappings to suit your needs.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | HTTP access to YACReaderLibraryServer. |
| `-p 8080` | HTTP access to YACReaderLibraryServer. |
| `-e PUID=99` | for UserID - see below for more information. |
| `-e PGID=100` | for GroupID - see below for more information. |
| `-e TZ=America/New_York` | Specify a timezone to use, e.g. America/New_York. |
| `-v /config` | Directory where YACReaderLibraryServer's configuration and log files will be stored. |
| `-v /comics` | The directory where YACReaderLibraryServer will look for your comics. |
|  `tag` | The docker tag will pull your chosen version YACReaderLibraryServer, the options are `pzip` or `unarr` (default). |

### User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, you can avoid this by specifying the user `PUID` and group `PGID`.

Ensure any mapped volume directories on your host machine are owned by the same user you specify and you will avoid any permissions issues.

In this instance `PUID=99` and `PGID=100`, to find yours using the following command:

```bash
  $ id <username> # Replace with your username
    uid=99(nobody) gid=100(users) groups=100(users)
```   

## Usage Instructions:

#### To create a new YACReader comics library run the  following command from the CLI on your host machine, changing `<library-name>` to whatever you want your library to be called:
````
docker exec YACReaderLibraryServer YACReaderLibraryServer create-library <library-name> /comics
````
#### To add an existing YACReader library:
````
docker exec YACReaderLibraryServer YACReaderLibraryServer add-library <library-name> /comics
````
#### To update your YACReader library (e.g. when you've added new comics):
````
docker exec YACReaderLibraryServer YACReaderLibraryServer update-library /comics
````
#### To list all existing YACReader libraries
````
docker exec YACReaderLibraryServer YACReaderLibraryServer list-libraries
````
#### To remove a YACReader library
````
docker exec YACReaderLibraryServer YACReaderLibraryServer remove-library <library-name>
````

You can also view YACReaderLibraryServer's limited WebUI by pointing your web browser to: 

* `http://SERVERIP:8080` (Replace `SERVERIP` with the correct value). 

**Please note**: YACReaderLibraryServer does not have authentication installed by default, so it is not advisable to expose your server outside of your home network. If you wish to be able to access YACReaderLibraryServer from outside your local network please use a reverse ssl proxy, such as NGINX with an .htaccess file, or a locally-hosted VPN, such as OpenVPN to access your local network.

## Versions

* **14.06.21:** - Switched to monorepo with unarr and p7zip versions.

* **11.06.21:** - Bug fix and patch on main p7zip branch.

* **10.06.21:** - Complete rebuild and inital version.


## Donations

If you appreciate my work please consider buying me a coffee, cheers! 😁

<a href="https://www.buymeacoffee.com/xthursdayx"><img src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" alt="Donate" style="width:74px;height:auto;" width="74"></a>
