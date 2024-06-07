import csv

filename = 'c:/Users/Fernando/Documents/GitHub/Redistribution/resources/trans_by.csv'
output_filename = 'c:/Users/Fernando/Documents/GitHub/Redistribution/resources/trans_by_aligned.csv'

with open(filename, 'r') as file:
    reader = csv.reader(file)
    rows = list(reader)

max_lengths = [max(len(row[i]) for row in rows) for i in range(len(rows[0]))]

with open(output_filename, 'w', newline='') as file:
    writer = csv.writer(file)
    for row in rows:
        writer.writerow([f'{cell:<{max_lengths[i]}}' for i, cell in enumerate(row)])