function handler(event) {
  var response = event.response;
  var headers = response.headers;

  //Set new headers
  headers['strict-transport-security'] = {'value': 'max-age=31536000'};
  // the following are not used as of 2018-12-26, but can be commented back in when appropriate
  //headers['content-security-policy'] = {'value': "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"};
  headers['x-content-type-options'] = {'value': 'nosniff'};
  headers['x-frame-options'] = {'value': 'DENY'};
  headers['x-xss-protection'] = {'value': '1; mode=block'};
  headers['referrer-policy'] = {'value': 'same-origin'};
  //Return modified response
  return response;
}
