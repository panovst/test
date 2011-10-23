package test.mina;

import org.apache.mina.core.future.CloseFuture;
import org.apache.mina.core.future.IoFutureListener;

public class MyIOListener implements IoFutureListener<CloseFuture>{

    public void operationComplete(CloseFuture paramF) {
        System.out.println("[MyIOListener] CloseFuture was Complete. isClosed: "+paramF.isClosed());
    }

}
