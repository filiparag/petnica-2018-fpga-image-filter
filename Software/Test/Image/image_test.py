#! /usr/bin/env python3

import numpy as np
from matplotlib import pyplot as plt


image = np.zeros((60,256))
for s in range(4):
    for y in range(len(image) // 4):
        for x in range(len(image[0])):
            image[s * 15 + y][x] = np.floor((y / (len(image) - 1) * ((s + 1) * 32)) + (x / (len(image[0]) - 1) * ((s + 1) * 32)))

def decode(file):

    columns = file.split('\n')[:-1]

    image = np.zeros((60,256), dtype=np.uint8)
    for c in range(len(columns)):
        columns[c] = [int(columns[c][i:i+8], 2) for i in range(0, len(columns[c]), 8)]
    columns = np.array(columns)
    # plt.imshow(columns[-520:])
    # plt.figure(2)

    print(len(columns))

    for c in range(len(columns)):
        row, column = c // 256, c % 256
        image[row, column] = columns[c][0]
        # if column == 0:
        #     print(row,row+15, column, c)
            
    # image[-1, :] = columns[len(columns) - len(image[0]):, -1]

    image = np.flip(image, axis=1)
    return image


with open('image_output.out', 'r') as file:
    image_out = np.flip(decode(file.read()), axis=1)
    
image_diff = image - image_out
error = np.count_nonzero(image_diff)

print('Error percentage : %s percent' % (round(error / image.size, 2) * 100))
print('Error count      : %s / %s pixel(s)' % (error, image.size))

plt.suptitle('Image test')
plt.subplot(3,1,1)
plt.imshow(image_out, vmin=0, vmax=255)
plt.subplot(3,1,2)
plt.imshow(image, vmin=0, vmax=255)
plt.subplot(3,1,3)
plt.imshow(image_diff)
# plt.figure(1)
# plt.imshow(image_out, cmap='gray')
# plt.figure(2)
# plt.imshow(image, cmap='gray')
plt.show()
