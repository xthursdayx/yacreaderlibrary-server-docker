<p align="center">
    <img src="https://raw.githubusercontent.com/xthursdayx/docker-templates/master/xthursdayx/images/yacreader-icon.png" alt="" width="150"/>  
</p>

# YACReaderLibraryServer Docker

[![Docker Builds](https://img.shields.io/github/actions/workflow/status/xthursdayx/yacreaderlibrary-server-docker/docker-build-and-publish.yml?style=for-the-badge&logo=githubactions&label=Image%20Builds
)](https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/main/.github/workflows/docker-build-and-publish.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/xthursdayx/yacreaderlibrary-server-docker?label=pulls&logo=docker&style=for-the-badge)
![Docker Pulls](https://img.shields.io/badge/Docker%20Architectures-amd64%20%7C%20arm64v8-informational?style=for-the-badge&logo=appveyor)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/xthursdayx/yacreaderlibrary-server-docker/unarr-amd64?label=unarr%20image&logo=ubuntu&size&style=for-the-badge)](https://hub.docker.com/r/xthursdayx/yacreaderlibrary-server-docker:unarr-amd64)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/xthursdayx/yacreaderlibrary-server-docker/7zip-amd64?label=7zip%20image%20size&logo=ubuntu&style=for-the-badge)](https://hub.docker.com/r/xthursdayx/yacreaderlibrary-server-docker:7zip-amd64)
[![GitHub Release](https://img.shields.io/github/v/release/xthursdayx/yacreaderlibrary-server-docker?style=for-the-badge&logo=github)](https://github.com/xthursdayx/yacreaderlibrary-server-docker/releases)
[![GitHub](https://img.shields.io/static/v1.svg?style=for-the-badge&label=xthursdayx&message=GitHub&logo=github)](https://github.com/xthursdayx "view the source for all of my repositories.")

Headless version of the [YACReaderLibraryServer](https://github.com/YACReader/yacreader/tree/develop/YACReaderLibraryServer), running on a custom base image built with [Ubuntu 26.04 LTS cloud image](https://cloud-images.ubuntu.com/) and [S6 overlay](https://github.com/just-containers/s6-overlay). 

[YACReader](https://www.yacreader.com/) is the best comic reader and comic manager available, with support for cbr, cbz, zip, and rar comic files. 

YACReaderLibraryServer makes it easy to run a home comics server to serve your comics to any device running a YACReader client (including [Windows, MacOS, and Linux](https://www.yacreader.com/downloads) as well [the YACReader iOS app](https://ios.yacreader.com/)).

## Setup Instructions:

There are two versions of the YACReaderLibraryServer image, each compiled with a different decompression backend:

* **`7zip`** (default, `latest`): uses [7-Zip](https://www.7-zip.org/) 23.01. This has the broadest format support, including RAR5 and 7z, and is the backend YACReader uses in its own official builds.
* **`libarchive`**: uses [libarchive](https://github.com/libarchive/libarchive). It handles zip, rar (including RAR5, with some limitations) and 7z without any non-free code, so pick it if GPL compatibility matters to you.

The old `unarr` backend has been retired, since upstream recommends libarchive over it (unarr has no RAR5 support). The `unarr` tag now points to the `libarchive` image so existing installs keep receiving updates; please switch your tag to `libarchive` or `latest`.

This docker image is also available from the GitHub container registry: `ghcr.io/xthursdayx/yacreaderlibrary-server-docker`

### Supported Architectures

Every tag is a multi-arch manifest covering `x86-64` (amd64) and `arm64`. Docker pulls the right image for your platform automatically.

| Tag | Backend |
| :----: | --- |
| `latest`, `7zip`, `<version>`, `7zip-<version>` | 7zip |
| `libarchive`, `libarchive-<version>` | libarchive |
| `unarr` | libarchive (transition alias, deprecated) |

The per-architecture tags (`unarr-amd64`, `7zip-arm64v8`, etc.) are no longer updated. If you pinned one of them, switch to one of the tags above.

Here are some examples to help you get started creating a container from this image. If you are an UNRAID user you can access my [UNRAID YACReaderLibraryServer template](https://raw.githubusercontent.com/xthursdayx/docker-templates/master/xthursdayx/yacserver.xml) in Community Apps.

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
| `-e PUID=99` | for UserID - see below for more information. |
| `-e PGID=100` | for GroupID - see below for more information. |
| `-e TZ=America/New_York` | Specify a timezone to use, e.g. America/New_York. |
| `-v /config` | Directory where YACReaderLibraryServer's configuration and log files will be stored. |
| `-v /comics` | The directory where YACReaderLibraryServer will look for your comics. |
|  `tag` | (Optional) The docker tag will pull your chosen version YACReaderLibraryServer, the primary options are `latest`/`7zip` (default) or `libarchive`, though arch and release specific tags are also available. |

### User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, you can avoid this by specifying the user `PUID` and group `PGID`.

Ensure any mapped volume directories on your host machine are owned by the same user you specify and you will avoid any permissions issues.

Your comics only need to be **readable** by this user. The container takes ownership of `/config` and of the `.yacreaderlibrary` folders where library data is stored, but it never changes the ownership of your comics.

In this instance `PUID=99` and `PGID=100`, to find yours using the following command:

```bash
  $ id <username> # Replace with your username
    uid=99(nobody) gid=100(users) groups=100(users)
```   

## Usage Instructions:

Run these commands from the CLI on your host machine. The `-u abc` makes them run as the same user as the server, so the library files they create stay writable by it.

#### To create a new YACReader comics library (change `<library-name>` to whatever you want your library to be called):
````
docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer create-library <library-name> /comics
````
#### To add an existing YACReader library:
````
docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer add-library <library-name> /comics
````
#### To update your YACReader library (e.g. when you've added new comics):
````
docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer update-library /comics
````
#### To list all existing YACReader libraries
````
docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer list-libraries
````
#### To remove a YACReader library
````
docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer remove-library <library-name>
````
Other commands (`repair-library`, `backup-library`, `restore-library`, `rescan-xml-info` and more) are listed by running `docker exec -u abc YACReaderLibraryServer YACReaderLibraryServer --help`.

#### Keeping libraries up to date automatically

Instead of running `update-library` by hand, open `http://SERVERIP:8080/webui/settings` and turn on updates at startup, periodically, or at a set time. You can also choose there whether ComicInfo.xml metadata is imported. Library updates pause writes to the database, so don't schedule them for a time when you're likely to be reading.

#### Health status

The image has a built-in healthcheck, so `docker ps`, Compose and the Unraid dashboard show whether the server is actually answering requests (`healthy`) rather than just running.

## Accessing YACReaderLibraryServer 

You can access your YACReaderLibraryServer by pointing your YACReader app to: 

* `http://SERVERIP:8080` (Replace `SERVERIP` with the correct value). 

**Please note**: YACReaderLibraryServer does not have authentication installed by default, so it is not advisable to expose your server outside of your home network. If you wish to be able to access YACReaderLibraryServer from outside your local network please use a reverse ssl proxy, such as NGINX with an .htaccess file, or a locally-hosted VPN, such as OpenVPN to access your local network.

## Updating Info

This image is static, versioned, and requires an image update and container recreation to update version of YACReaderLibraryServer running inside. 

Here are the instructions for updating containers:
### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull YACReaderLibraryServer`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d YACReaderLibraryServer`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull xthursdayx/YACReaderLibraryServer`
* Stop the running container: `docker stop YACReaderLibraryServer`
* Delete the container: `docker rm YACReaderLibraryServer`
* Recreate a new container with the same docker run parameters as described above (if mapped correctly, your YACReaderLibraryServer database and library will be preserved).
* You can also remove the old dangling images: `docker image prune`

### Image Update Notifications - Diun (Docker Image Update Notifier)

* You can use [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended.

## Versions

* **29.10.26:** - Add a healthcheck, stop changing ownership of comic files, build arm64 natively and smoke-test every image before publishing.
* **23.10.26:** - Update YACReader to 10.4.0 (CMake build, Qt6, rebase to Ubuntu 26.04). Single multi-stage Dockerfile for all variants; `7zip` becomes the default and `libarchive` replaces `unarr`.

* **15.02.24:** - Roll aarch64 images back to QT5 to temporarily fix CI build issue.

* **15.02.24:** - Update YACReader to 9.14.2, swith p7zip branch to 7zip and update to QT6 for the `7zip` image.

* **06.02.24:** - Update YACReader to 9.14.1 and update to QT6 for the `unarr` image.

* **28.07.23:** - Update YACReader to 9.13.1 and depreciated 32-bit Arm(hf) image.

* **25.04.23:** - Update YACReader to 9.12.0.

* **04.04.23:** - Update YACReader to 9.11.0 and fix CI build process.

* **02.12.22:** - Update YACReader to 9.10.0 and upgrade to s6v3.

* **27.10.22:** - Updated to YACReaderLibrary 9.9.2 and rebase to Jammy.

* **16.11.21:** - Streamlined multi-arch support and docker image push workflow.

* **20.06.21:** - Added multi-arch support.

* **14.06.21:** - Switched to monorepo with unarr and p7zip versions.

* **11.06.21:** - Bug fix and patch on main p7zip branch.

* **10.06.21:** - Complete rebuild and initial version.


## Donations

If you appreciate my work please consider buying me a coffee, cheers! 😁

<a href="https://www.buymeacoffee.com/xthursdayx"><img src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" alt="Donate" style="width:74px;height:auto;" width="74"></a>
