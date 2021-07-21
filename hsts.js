function handler(event) {
  var response = event.response;
  var headers = response.headers;

  //Set new headers
  headers['strict-transport-security'] = {'value': 'max-age=31536000'};

  //Return modified response
  return response;
}
