<p align="center">
    <img src="https://raw.githubusercontent.com/xthursdayx/docker-templates/blob/master/images/yacreader-icon.png" alt="" width="150"/>  
</p>

Fork of [muallin's YACReaderLibraryServer Docker](https://hub.docker.com/r/muallin/yacreaderlibrary-server-docker/) with updated YACReader and base image. 

# YACReaderLibrary Server Docker

Headless version of the [YACReaderLibraryServer](https://github.com/YACReader/yacreader/tree/develop/YACReaderLibraryServer). [YACReader](https://www.yacreader.com/) is the best comic reader and comic manager with support for cbr, cbz, zip, and rar comic files.

### Install:

You can run this docker with the following command:

````
docker run -d \
  --name="yacserver" \
  -e TZ="America/New_York"
  -v /path/to/comics:/comics:rw \
  -p <port>:8080 \
  xthursdayx/yacreaderlibrary-server-docker
 ```` 

### Setup Instructions:

- Replace "/path/to/comics" with the local location of your comcis folder.
- Replace "<port>" with your choice of ports.

#### Create new YACReader library
````
docker exec yacserver YACReaderLibraryServer create-library <library-name> /comics
````
#### Add existing YACReader library
````
docker exec yacserver YACReaderLibraryServer add-library <library-name> /comics
````
#### Update YACReader library (e.g. when you've added new comics)
````
docker exec yacserver YACReaderLibraryServer update-library /comics
````
#### List existing YACReader libraries
````
docker exec yacserver YACReaderLibraryServer list-libraries
````
#### Remove YACReader library
````
docker exec yacserver YACReaderLibraryServer remove-library <library-name>
````
