package handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import response.LambdaResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

/**
 * @author pramesh-bhattarai
 */
public class LambdaHandler implements RequestHandler<Map<String,Object>, LambdaResponse> {

    @Override
    public LambdaResponse handleRequest(Map<String,Object> input, Context context) {
        LambdaLogger logger = context.getLogger();
        logger.log(input.toString());

        LambdaResponse lambdaResponse = new LambdaResponse();
        Map<String, String> headers = new HashMap<>();
        headers.put("Access-Control-Allow-Origin", "*");
        lambdaResponse.setHeaders(headers);
        lambdaResponse.setStatusCode(200);
        try {
            URL obj = new URL("http://dummy.restapiexample.com/api/v1/employees");
            HttpURLConnection con = (HttpURLConnection) obj.openConnection();
            con.setRequestMethod("GET");
            int responseCode = con.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) { // success
                StringBuilder response = new StringBuilder();
                try (BufferedReader in = new BufferedReader(
                        new InputStreamReader(con.getInputStream())
                )) {
                    String inputLine;
                    while ((inputLine = in.readLine()) != null) {
                        response.append(inputLine);
                    }
                }
                logger.log(response.toString());
                lambdaResponse.setBody(response.toString());
            }
        } catch (IOException e) {
            logger.log(e.getMessage());
            lambdaResponse.setBody("Unable to get response from endpoint...");
        }
        logger.log("sending response");
        return lambdaResponse;
    }

}
