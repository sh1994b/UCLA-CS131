import asyncio


async def tcp_echo_client(message):
    reader, writer = await asyncio.open_connection('127.0.0.1', 11565)
    writer.write(message.encode())
    await writer.drain()
    data = await reader.read(100)
    writer.close()
    print(data.decode())

asyncio.run(tcp_echo_client('IAMAT kiwi.cs.ucla.edu                                                                +34.06893-118.445127 1520023934.918963997\n'))
#asyncio.run(tcp_echo_client('WHATSAT kiwi.cs.ucla.edu 50 1\n'))



