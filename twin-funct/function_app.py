import logging
import azure.functions as func
import azure.identity as ident
import azure.digitaltwins.core as dt
import json

app = func.FunctionApp()

@app.function_name(name="devtocloudevent")
@app.event_grid_trigger(arg_name="event")
def main(event: func.EventGridEvent):
    adturl = "https://smarthome-twin.api.weu.digitaltwins.azure.net"
    cred = ident.DefaultAzureCredential()
    client = dt.DigitalTwinsClient(adturl, cred)
    result = json.dumps({
        'id': event.id,
        'data': event.get_json(),
        'topic': event.topic,
        'subject': event.subject,
        'event_type': event.event_type,
    })

    # Python EventGrid trigger processed an event: {"id": "d7b1640b-70fb-382a-8ebc-aa468ac2f6d6", "data": {"properties": {}, "systemProperties": {"iothub-connection-device-id": "ESP8266", "iothub-connection-auth-method": "{\"scope\":\"device\",\"type\":\"sas\",\"issuer\":\"iothub\",\"acceptingIpFilterRule\":null}", "iothub-connection-auth-generation-id": "638334935416204108", "iothub-enqueuedtime": "2023-10-22T11:28:09.91Z", "iothub-message-source": "Telemetry"}, "body": "eyJodW1pZGl0eSI6NDIuOCwidGVtcGVyYXR1cmUiOjIyLjQsInRlbXBlcmF0dXJlX2ZlZWwiOjIxLjgsImlkIjoic2Vuc29yMSJ9"}, "topic": "/SUBSCRIPTIONS/C5CB8E41-F0E1-484C-B4EE-F678A6C485A4/RESOURCEGROUPS/RG-SA-DEV/PROVIDERS/MICROSOFT.DEVICES/IOTHUBS/SMARTIOTHUB70", "subject": "devices/ESP8266", "event_type": "Microsoft.Devices.DeviceTelemetry"}
    logging.info('Python EventGrid trigger processed an event: %s', result)

    if (event and bool(event.__data)):
        msg = event.get_json()

    """                  if (eventGridEvent != null && eventGridEvent.Data != null)
                {
                    _logger.LogInformation(eventGridEvent.Data.ToString());

                    // <Find_device_ID_and_temperature>
                    JObject deviceMessage = (JObject)JsonConvert.DeserializeObject(eventGridEvent.Data.ToString());
                    string deviceId = (string)deviceMessage["systemProperties"]["iothub-connection-device-id"];
                    JObject body = (JObject)JsonConvert.DeserializeObject(DecodeBase64((string)deviceMessage["body"]));
                    var temperature = body["temperature"];
                    var humidity = body["humidity"];
                    // </Find_device_ID_and_temperature>

                    _logger.LogInformation($"Device:{deviceId} Temperature is:{temperature}");

                    // <Update_twin_with_device_temperature>
                    var updateTwinData = new JsonPatchDocument();
                    updateTwinData.AppendReplace("/Temperature", temperature.Value<double>());
                    updateTwinData.AppendReplace("/Humidity", humidity.Value<double>());
                    client.UpdateDigitalTwin(deviceId, updateTwinData);
                    // </Update_twin_with_device_temperature>
                } """