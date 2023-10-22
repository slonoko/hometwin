import logging
import azure.functions as func
import azure.identity as ident
import azure.digitaltwins.core as dt
import json
import base64

app = func.FunctionApp()
adturl = "https://smarthome-twin.api.weu.digitaltwins.azure.net"
cred = ident.DefaultAzureCredential()

@app.function_name(name="devtocloudevent")
@app.event_grid_trigger(arg_name="event")
def main(event: func.EventGridEvent):

    client = dt.DigitalTwinsClient(adturl, cred)
    # Python EventGrid trigger processed an event: {"id": "d7b1640b-70fb-382a-8ebc-aa468ac2f6d6", 
    # "data": {
    #   "properties": {}, 
    #   "systemProperties": {
    #   "iothub-connection-device-id": "ESP8266", 
    #   "iothub-connection-auth-method": "{\"scope\":\"device\",\"type\":\"sas\",\"issuer\":\"iothub\",\"acceptingIpFilterRule\":null}", 
    #   "iothub-connection-auth-generation-id": "638334935416204108", 
    #   "iothub-enqueuedtime": "2023-10-22T11:28:09.91Z", 
    #   "iothub-message-source": "Telemetry"
    #   }, 
    #   "body": "eyJodW1pZGl0eSI6NDIuOCwidGVtcGVyYXR1cmUiOjIyLjQsInRlbXBlcmF0dXJlX2ZlZWwiOjIxLjgsImlkIjoic2Vuc29yMSJ9"
    # }, 
    # "topic": "/SUBSCRIPTIONS/C5CB8E41-F0E1-484C-B4EE-F678A6C485A4/RESOURCEGROUPS/RG-SA-DEV/PROVIDERS/MICROSOFT.DEVICES/IOTHUBS/SMARTIOTHUB70", 
    # "subject": "devices/ESP8266", 
    # "event_type": "Microsoft.Devices.DeviceTelemetry"}
    if (event and bool(event.get_json())):
        msg = event.get_json()
        prop = msg["systemProperties"]
        device_id= prop["iothub-connection-device-id"]
        body = json.loads(base64.b64decode(msg["body"]))
        temperature = body["temperature"]
        humidity = body["humidity"]
        logging.info('Device: %s, Temperature is: %s', device_id, temperature)
        updateTwinData = [{"Temperature":temperature},{"Humidity":humidity}]
        client.update_digital_twin(device_id, updateTwinData)