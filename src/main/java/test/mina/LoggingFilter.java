package test.mina;

import java.util.Date;

import org.apache.mina.core.filterchain.IoFilterAdapter;
import org.apache.mina.core.filterchain.IoFilterChain;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.core.write.WriteRequest;

public class LoggingFilter extends IoFilterAdapter {

    @Override
    public void exceptionCaught(NextFilter nextFilter, IoSession session,
            Throwable cause) throws Exception {
        cause.printStackTrace();
        nextFilter.exceptionCaught(session, cause);
    }
    
    @Override
    public void destroy() throws Exception {
        System.out.println("[LoggingFilter] destroy");
    }
    
    @Override
    public void filterClose(NextFilter nextFilter, IoSession session)
            throws Exception {
        System.out.println("[LoggingFilter] filterClose");
        nextFilter.filterClose(session);
    }
    
    @Override
    public void filterWrite(NextFilter nextFilter, IoSession session,
            WriteRequest writeRequest) throws Exception {
        System.out.println("[LoggingFilter] filterWrite");
        nextFilter.filterWrite(session, writeRequest);
    }
    
    @Override
    public void messageReceived(NextFilter nextFilter, IoSession session,
            Object message) throws Exception {
        System.out.println("[LoggingFilter] messageReceived");
        nextFilter.messageReceived(session, message);
    }
    
    @Override
    public void messageSent(NextFilter nextFilter, IoSession session,
            WriteRequest writeRequest) throws Exception {
        System.out.println("[LoggingFilter] messageSent");
        nextFilter.messageSent(session, writeRequest);
    }
    
    @Override
    public void onPostAdd(IoFilterChain parent, String name,
            NextFilter nextFilter) throws Exception {
        System.out.println("[LoggingFilter] onPostAdd");
    }
    
    @Override
    public void onPostRemove(IoFilterChain parent, String name,
            NextFilter nextFilter) throws Exception {
        System.out.println("[LoggingFilter] onPostRemove");
    }
    
    @Override
    public void onPreAdd(IoFilterChain parent, String name,
            NextFilter nextFilter) throws Exception {
        System.out.println("[LoggingFilter] onPreAdd");
    }
    
    @Override
    public void onPreRemove(IoFilterChain parent, String name,
            NextFilter nextFilter) throws Exception {
        System.out.println("[LoggingFilter] onPreRemove");
    }
    
    @Override
    public void sessionClosed(NextFilter nextFilter, IoSession session)
            throws Exception {
        System.out.println("[LoggingFilter] sessionClosed");
        nextFilter.sessionClosed(session);
    }
    
    @Override
    public void sessionCreated(NextFilter nextFilter, IoSession session)
            throws Exception {
        System.out.println("[LoggingFilter] sessionCreated");
        nextFilter.sessionCreated(session);
    }
    
    @Override
    public void sessionIdle(NextFilter nextFilter, IoSession session,
            IdleStatus status) throws Exception {
        System.out.println("[LoggingFilter] sessionIdle");
        nextFilter.sessionIdle(session, status);
    }
    
    @Override
    public void sessionOpened(NextFilter nextFilter, IoSession session)
            throws Exception {
        System.out.println("[LoggingFilter] sessionOpened");
        nextFilter.sessionOpened(session);
    }
}
