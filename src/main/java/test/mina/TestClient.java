package test.mina;

import java.net.Socket;
import java.util.concurrent.TimeUnit;

public class TestClient {

    public static void main(String[] args) {
        try {
            Socket client = new Socket("localhost", MinaTimeServer.PORT);
            
            TimeUnit.SECONDS.sleep(60);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
