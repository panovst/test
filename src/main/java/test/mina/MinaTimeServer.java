package test.mina;

import java.net.InetSocketAddress;
import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;

import org.apache.mina.core.service.IoAcceptor;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.codec.textline.TextLineCodecFactory;
import org.apache.mina.transport.socket.nio.NioSocketAcceptor;

public class MinaTimeServer {
    
    public static final int PORT = 10123;
    
    public static void main(String[] args) {
        IoAcceptor acceptor = null;
        try {
            acceptor = new NioSocketAcceptor();
            
            acceptor.getFilterChain().addLast( "logger", new LoggingFilter() );
            acceptor.getFilterChain().addLast( "codec", new ProtocolCodecFilter( new TextLineCodecFactory( Charset.forName( "UTF-8" ))));
            
            acceptor.setHandler(  new TimeServerHandler() );
            
            acceptor.getSessionConfig().setReadBufferSize( 2048 );
            acceptor.getSessionConfig().setIdleTime( IdleStatus.BOTH_IDLE, 10 );
            
            acceptor.bind( new InetSocketAddress("localhost", PORT) );
            
            TimeUnit.SECONDS.sleep(10800);
            System.out.println("Server DONE");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (acceptor != null) {
                acceptor.unbind();
            }
        }
    }
}