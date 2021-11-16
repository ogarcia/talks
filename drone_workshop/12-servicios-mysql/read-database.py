#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2018 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.

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
        # Read all records
        sql = 'SELECT * FROM `user`'
        cursor.execute(sql, )
        results = cursor.fetchall()
        print('RAW data in user table:')
        for result in results:
            print(result)
        print('\nUsers:')
        for result in results:
            print('{username} - {firstname} {lastname} - {email}'.format(**result))

finally:
    connection.close()
