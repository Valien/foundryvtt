#!/usr/local/bin python3

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
def get_images(BaseURL):
    """
    Gets the images!
    """
    soup = bs(requests.get(BaseURL).content, "html.parser")
    urls = []
    for img in tqdm(soup.find_all("a"), "Getting images"):
        img_url = img.attrs.get("href")
        if not img_url:
            continue
        img_url = urljoin(BaseURL, img_url)
        if is_valid(img_url):
            urls.append(img_url)
    return urls

def download(url, pathname):
    """
    Downloads a file given an URL and puts it in the folder `pathname`
    """
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

# def getList():
#     list = requests.get(BaseURL)
#     #print(list.text)
#     with open("image_list.txt", 'wb') as f:
#         f.write(list.content)

# def readFile():
#     filelines = []
#     with open("image_list.txt", 'rt') as imagefile:
#         for fileline in imagefile:
#             filelines.append(fileline)
#     print(filelines[14])

# def get_images(moyr, numimages):
#     print('Acquiring images...')

#     images =requests.get(BaseURL)
#     open("$HOME/Desktop/dnd_images/")
    
#     for n in range(numimages):
#         ''' 
#             This function get's the images. Yar! Does require you to enter Month and Number of images.
#         '''    
#         if n < 10:
#             urltoparse = BaseURL + moyr + '/digitalsavings_' + str(n).zfill(2) + ".png"
#             print(urltoparse)
#             response = requests.get(urltoparse)  # + str(n))
#             if response.status_code == 200:
#                 # to do: remove my hard-coded desktop location...
#                 with open("/Users/allen.vailliencourt/Desktop/hf/" + moyr + '-' + str(n) + '.png', 'wb') as f:
#                     f.write(response.content)
#             else:
#                 print(f'Error! {response.status_code}')
#         else:
#             urltoparse = BaseURL + moyr + '/images/' + str(n) + ".jpg"
#             print(urltoparse)
#             response = requests.get(urltoparse)
#             if response.status_code == 200:
#                 # to do: see above.
#                 with open("/Users/allen.vailliencourt/Desktop/hf/" + moyr + '-' + str(n) + '.png', 'wb') as f:
#                     f.write(response.content)
#             else:
#                 print(f'Error! {response.status_code}')

#print(f'Now parsing images from {BaseURL}\n')
#print('All done!\n')
#get_images(my_input, numrange_input)
#getList()
#readFile()
main("http://www.dmcodex.us/img/WDH/", "test")