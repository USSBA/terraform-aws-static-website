function handler(event) {

    var index_file = "DEFAULT_INDEX";
    var trailing_slash_to_index = TRAILING_SLASH_TO_INDEX;
    var no_file_extension_to_index = NO_FILE_EXTENSION_TO_INDEX;

    // Extract the request from the CloudFront event that is sent to Lambda@Edge
    var request = event.request;

    // Extract the URI from the request
    var olduri = request.uri;
    var newuri = request.uri;

    // Match any '/' that occurs at the end of a URI. Replace it with a default index
    if ( trailing_slash_to_index ) {
      newuri = olduri.replace(/\/$/, `/${index_file}`);
    }

    // Match any URL that ends in /<something-without-a-dot>; append /index.html
    //   ex: example.com/foo/bar => example.com/foo/bar/index.html
    if (no_file_extension_to_index && newuri.match(/\/[^\/\.]+$/)) {
      newuri = newuri + `/${index_file}`
    }

    console.log("Old URI: " + olduri);
    console.log("New URI: " + newuri);

    // Replace the received URI with the URI that includes the index, if applicable
    request.uri = newuri;

    // Return to CloudFront
    return request;

};
