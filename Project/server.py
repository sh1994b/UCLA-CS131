import aiohttp
import sys
import asyncio
import logging
import time
import json

serverName = "global"
host = '127.0.0.1'
serverConnections = {'Goloman': ['Hands', 'Holiday', 'Wilkes'],
		     'Hands': ['Wilkes', 'Goloman'],
		     'Holiday': ['Welsh', 'Wilkes', 'Goloman'],
		     'Wilkes': ['Goloman', 'Hands', 'Holiday'],
		     'Welsh': ['Holiday']}

portNums = {'Goloman': 11565,
	    'Hands': 11566,
	    'Holiday': 11567,
	    'Welsh': 11568,
            'Wilkes': 11569}

clients = {}

myAPIKey = "Erased for security; replace with your API key!"


async def handle_connection(reader, writer):
  while not reader.at_eof():
    data = await reader.readline()
    logging.info(data)
    serverTime = time.time()
    message = data.decode()
    response = await process_input(message,serverTime)
    logging.info(response)
    writer.write(response.encode())
    await writer.drain()
  writer.close()



async def process_input(data,serverTime):
  splitData = data.split()
  if len(splitData) == 4:
    clientID = splitData[1]    
    if splitData[0] == "IAMAT" or splitData[0] == "AT":
      clientLoc = splitData[2]
      clientTime = splitData[3]
      timeDiff = serverTime - float(clientTime)
      atlst = ["AT", serverName, str(timeDiff), clientID, clientLoc, clientTime] 
      result = ' '.join(atlst)
      if clientID in clients:
        existingClient = clients[clientID]
        if existingClient[0] != clientLoc or existingClient[1] != clientTime:
          #only update the dictionary if time stamp is newer than what we already have:
          if float(clientTime) >= float(clients[clientID][1]):
            await flood_to_servers(result)
            clients[clientID] = [clientLoc, clientTime]
      else:
        await flood_to_servers(result)
        clients[clientID] = [clientLoc, clientTime]
      if splitData[0] == "AT":
        return
      return result
  
    if splitData[0] == "WHATSAT":
      radius = int(splitData[2])
      upperbound = int(splitData[3])
      if radius > 50 or upperbound > 20 or not clientID in clients:
        result = await bad_data(data)
        return result
      location = clients[clientID][0]
      places = await ask_Google(location, radius, upperbound)
      timeDiff = serverTime - float(clients[clientID][1])
      atlst = ["AT", serverName, str(timeDiff), clientID, clients[clientID][0], clients[clientID][1]]
      atstr = ' '.join(atlst)
      atAndPlacesLst = [atstr, places]
      result = "\n".join(atAndPlacesLst)
      return result
      
  result = await bad_data(data)
  return result 


async def bad_data(data):
  invalidlst = ["?", data]
  result = ' '.join(invalidlst)
  return result


async def flood_to_servers(message):
  friends = serverConnections[serverName]
  for friend in friends:
    try:
      port = portNums[friend]
      reader, writer = await asyncio.open_connection(host, port)
      logging.info("New connection to %s",friend)
      writer.write(message.encode())
      await writer.drain()
      writer.close()
      await writer.wait_closed()
      logging.info("Dropped connection with %s",friend) 
    except:
      pass


async def ask_Google(loc, radius, numresults):
  location = await get_coordinates(loc) 
  MyUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={0}&radius={1}&key={2}'.format(location, radius, myAPIKey)
  async with aiohttp.ClientSession() as session:
    async with session.get(MyUrl) as resp:
      response = await resp.text()
      jsonData = json.loads(response)
      jsonData['results'] = jsonData['results'][0:int(numresults)-1]
      return json.dumps(jsonData, indent=3)


async def get_coordinates(loc):
  strlist = list(loc)
  for i in range(len(strlist)):
    if strlist[i] == '+' or strlist[i] == '-':
      count = i
  lat = ''.join(strlist[0:count-1])
  lon = ''.join(strlist[count:len(strlist)])
  return lat + "," + lon


async def main():
  if len(sys.argv) != 2:
    sys.exit(1)
  global serverName 
  serverName = sys.argv[1]
  lognamelst = [serverName, "log"]
  logname = '.'.join(lognamelst)
  logging.basicConfig(filename=logname, level=logging.INFO, format='%(asctime)s %(message)s')

  port = portNums[serverName]

  server = await asyncio.start_server(handle_connection, host, port)
  async with server:
    await server.serve_forever()



asyncio.run(main())



#when do you open connections to the servers that you talk to?
#how to use aiohttp lib?
