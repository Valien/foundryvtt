#!/usr/local/bin python3

import requests

BaseURL = 'http://www.dmcodex.us/img/WDH/'

def getList():
    list = requests.get(BaseURL)
    #print(list.text)
    with open("image_list.txt", 'wb') as f:
        f.write(list.content)

def readFile():
    filelines = []
    with open("image_list.txt", 'rt') as imagefile:
        for fileline in imagefile:
            filelines.append(fileline)
    print(filelines[14])

def get_images(moyr, numimages):
    print('Acquiring images...')

    images =requests.get(BaseURL)
    open("$HOME/Desktop/dnd_images/")
    
    for n in range(numimages):
        ''' 
            This function get's the images. Yar! Does require you to enter Month and Number of images.
        '''    
        if n < 10:
            urltoparse = BaseURL + moyr + '/digitalsavings_' + str(n).zfill(2) + ".png"
            print(urltoparse)
            response = requests.get(urltoparse)  # + str(n))
            if response.status_code == 200:
                # to do: remove my hard-coded desktop location...
                with open("/Users/allen.vailliencourt/Desktop/hf/" + moyr + '-' + str(n) + '.png', 'wb') as f:
                    f.write(response.content)
            else:
                print(f'Error! {response.status_code}')
        else:
            urltoparse = BaseURL + moyr + '/images/' + str(n) + ".jpg"
            print(urltoparse)
            response = requests.get(urltoparse)
            if response.status_code == 200:
                # to do: see above.
                with open("/Users/allen.vailliencourt/Desktop/hf/" + moyr + '-' + str(n) + '.png', 'wb') as f:
                    f.write(response.content)
            else:
                print(f'Error! {response.status_code}')

#print(f'Now parsing images from {BaseURL}\n')
#print('All done!\n')
#get_images(my_input, numrange_input)
getList()
readFile()

