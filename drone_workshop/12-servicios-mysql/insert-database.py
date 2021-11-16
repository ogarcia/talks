#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2018 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.

import hashlib
import pymysql.cursors

# Connect to the database
connection = pymysql.connect(host='database',
                             user='user',
                             password='passwd',
                             db='db',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)

try:
    with connection.cursor() as cursor:
        # Create a new record
        sql = 'INSERT INTO `user` (`username`, `password`, `firstname`, `lastname`, `email`) VALUES (%s, %s, %s, %s, %s)'
        hash = hashlib.sha1()
        hash.update(b'PabloDronePassword')
        cursor.execute(sql, ('pdrone', hash.hexdigest(), 'Pablo', 'Drone', 'padron@example.com'))
        connection.commit()

        # Read the record
        sql = 'SELECT * FROM `user` WHERE `email`=%s'
        cursor.execute(sql, ('padron@example.com', ))
        results = cursor.fetchall()
        print('RAW data in user table:')
        for result in results:
            print(result)
        print('\nUsers:')
        for result in results:
            print('{username} - {firstname} {lastname} - {email}'.format(**result))

finally:
    connection.close()
