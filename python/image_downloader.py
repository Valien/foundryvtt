#!/usr/local/bin python3

# all credit to this tutorial - https://www.thepythoncode.com/article/download-web-page-images-python
# with some additions/modifications by me.

import requests
import os
from tqdm import tqdm
from bs4 import BeautifulSoup as bs
from urllib.parse import urljoin, urlparse

BaseURL = 'http://www.dmcodex.us/img/WDH/'


def is_valid(BaseURL):
    """
    Checking if url is valid
    netloc = domain name
    scheme = protocol
    """
    parsed = urlparse(BaseURL)
    return bool(parsed.netloc) and bool(parsed.scheme)

# What i need to parse: <a href="Bonnie.png">Bonnie.png</a>
# html: <img src="image.png">
# example: http://www.dmcodex.us/img/WDH/Xanathar.png
def get_images(BaseURL):
    """
    Gets the images!
    """
    soup = bs(requests.get(BaseURL).content, "html.parser")
    urls = []
    for img in tqdm(soup.find_all('a'), "Getting images"):
        print(img.get('href'))
        img_url = img.attrs.get("href")
        if not img_url:
            continue
        img_url = urljoin(BaseURL, img_url)
        if is_valid(img_url):
            urls.append(img_url)
    del urls[0] # removes the initial ../ from the dict
    return urls

def download(url, pathname):
    """
    Downloads a file given an URL and puts it in the folder `pathname`
    """
    buffer_size = 1024
    # if path doesn't exist, make that path dir
    if not os.path.isdir(pathname):
        os.makedirs(pathname)
    # download the body of response by chunk, not immediately
    response = requests.get(url, stream=True)
    # get the total file size
    file_size = int(response.headers.get("Content-Length", 0))
    # get the file name
    filename = os.path.join(pathname, url.split("/")[-1])
    # progress bar, changing the unit to bytes instead of iteration (default by tqdm)
    progress = tqdm(response.iter_content(buffer_size), f"Downloading {filename}", total=file_size, unit="B", unit_scale=True, unit_divisor=1024)
    with open(filename, "wb") as f:
        for data in progress:
            # write data read to the file
            f.write(data)
            # update the progress bar manually
            progress.update(len(data))

def main(BaseURL, path):
    # get all images
    imgs = get_images(BaseURL)
    for img in imgs:
        download(img, path)

main("http://www.dmcodex.us/img/WDH/", "tokens")