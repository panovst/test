package test.mina;
import java.util.Date;

import org.apache.mina.core.future.CloseFuture;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;

public class TimeServerHandler extends IoHandlerAdapter
{
    @Override
    public void exceptionCaught( IoSession session, Throwable cause ) throws Exception
    {
        cause.printStackTrace();
    }

    @Override
    public void messageReceived( IoSession session, Object message ) throws Exception
    {
        String str = message.toString();
        if( str.trim().equalsIgnoreCase("quit") ) {
            session.close();
            return;
        }

        CloseFuture cf = session.close(true);
        cf.addListener(new MyIOListener());
        System.out.println("[TimeServerHandler] isClosing: "+session.isClosing());
        System.out.println("[TimeServerHandler] isConnected: "+session.isConnected());
        Date date = new Date();
        session.write( date.toString() );
        
        StackTraceElement[] elms = Thread.currentThread().getStackTrace();
        for (StackTraceElement el : elms) {
            System.err.println(el.toString());
        }

    }

    @Override
    public void sessionIdle( IoSession session, IdleStatus status ) throws Exception
    {
        System.out.println( "IDLE " + session.getIdleCount( status ));
    }
    
}