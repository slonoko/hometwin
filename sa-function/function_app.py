import logging
import azure.functions as func
import azure.identity as ident
import azure.digitaltwins.core as dt


app = func.FunctionApp()

@app.event_grid_trigger(arg_name="azeventgrid")
def dev_clo_trigger(azeventgrid: func.EventGridEvent):
    adturl = "https://smarthome-twin.api.weu.digitaltwins.azure.net"
    cred = ident.DefaultAzureCredential()
    client = dt.DigitalTwinsClient(adturl, cred)
    logging.info('ADT service client connection created.')

"""     if (azeventgrid != None and azeventgrid.__data != None):
        logging.info(azeventgrid.__data.__str__)

                if (eventGridEvent != null && eventGridEvent.Data != null)
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