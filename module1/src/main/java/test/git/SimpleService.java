package test.git;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Service;
import org.osgi.service.component.ComponentContext;

@Component(immediate=true)
@Service(value=SimpleService.class)
public class SimpleService {

    protected void activate(ComponentContext context) {
    	System.out.println("[SimpleService] activate context: " + context);
    }

    protected void deactivate(ComponentContext context) {
    	System.out.println("[SimpleService] deactivate context: " + context);
    }

}
