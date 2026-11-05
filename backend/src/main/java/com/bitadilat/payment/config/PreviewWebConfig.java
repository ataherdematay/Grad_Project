package com.bitadilat.payment.config;

import java.nio.file.Path;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Prototipi API ile aynı origin'den sunar; böylece CORS veya proxy gerekmez ve banka dönüşü
 * simülatöre ulaşabilir. Yalnızca preview/ klasörü açılır, repo kökü (.git vb.) açılmaz.
 */
@Configuration
public class PreviewWebConfig implements WebMvcConfigurer {

    private final String previewLocation;

    public PreviewWebConfig(@Value("${bitadilat.preview-dir}") String previewDir) {
        this.previewLocation = Path.of(previewDir).toAbsolutePath().normalize().toUri().toString();
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/preview/**").addResourceLocations(previewLocation).setCachePeriod(0);
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addRedirectViewController("/", "/preview/index.html");
    }
}
