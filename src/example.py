'''
 Copyright (C) 2023  Jakub Krsko

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 traininfo is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

from requests import Request, Session
import json

def getData(number:int = None):
    try:
        number = int(number)       
    except ValueError:
        return '{"id":0}'
    else:
        request = Request("GET", "https://tis.zsr.sk/mapavlakov/api/osobne").prepare()
        s = Session()
        response = s.send(request)
        response_obj = json.loads(response.text)
        for vlak in response_obj:
            if vlak.get("CisloVlaku") == number:
                return json.dumps(vlak)
        return '{"id":0}'     

def getAllData():
    request = Request("GET", "https://tis.zsr.sk/mapavlakov/api/osobne").prepare()
    s = Session()
    response = s.send(request)
    response_obj = json.loads(response.text)
    return json.dumps(response_obj)
